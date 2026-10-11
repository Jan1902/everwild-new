class_name ObjektAnsicht
extends Node2D
## Zeigt ein Objekt der Welt: als gemaltes Bild, wenn es eines gibt, sonst als gezeichneten Platzhalter.

const BILDORDNER := "res://assets/objekte/"
## Durchsichtiger Rand links und rechts als Anteil der Inhaltsbreite. Muss zu
## tools/zuschneiden.py passen. Der Wind-Shader braucht ihn als Platz zum Schwanken.
const RAND := 0.12
## Wie die Bilder in der Welt sitzen:
##   breite   Breite des Bildinhalts in Weltpixeln
##   fuss     Stelle im Bildinhalt (Anteil von Breite und Höhe), die auf dem Boden steht
##   versatz  Lage dieser Stelle relativ zur Mitte der Grundfläche
##   wind     wiegt sich im Wind
##   licht    Stelle einer Lichtquelle, in Weltpixeln relativ zum Fuß
##   stand    Radius des weichen Schattens direkt am Fuß, der das Objekt am Boden verankert
##   kasten   Wand- und Firsthöhe in Weltpixeln; der Schatten wird dann aus der Grundfläche
##            berechnet statt aus der Silhouette
const BILDER := {
	"haus": {"breite": 298.0, "fuss": Vector2(0.51, 0.985), "versatz": Vector2(0, 64), "kasten": Vector2(105, 215)},
	"baum": {"breite": 190.0, "fuss": Vector2(0.49, 0.97), "wind": true, "stand": 38.0},
	"stein": {"breite": 84.0, "fuss": Vector2(0.5, 0.78), "stand": 50.0},
	"laterne": {"breite": 85.0, "fuss": Vector2(0.19, 0.97), "licht": Vector2(48, -70), "stand": 18.0},
	"bruecke": {"breite": 180.0, "fuss": Vector2(0.5, 0.45)},
}
const LICHTFARBE := Color(1.0, 0.78, 0.42)

## Helligkeit aller Lichter, gesetzt aus der Stimmung der Welt.
static var licht := 1.0
## Schattenwurf in der Bodenebene, gesetzt aus der Stimmung der Welt.
static var schattenwurf := Vector2(0.5, 0.2)

static var _wind_stoff: ShaderMaterial
static var _schatten_stoff: ShaderMaterial
static var _lichtfleck: GradientTexture2D
static var _standfleck: GradientTexture2D

var art := ""
var groesse := Vector2i.ONE

var _bild: Sprite2D
var _schein: Sprite2D
var _flackern := 0.0


## Richtet das Objekt ein. Der Knoten sitzt in der Mitte seiner Grundfläche, damit die
## Tiefensortierung nach y stimmt.
func richte_ein(objekt: Dictionary) -> void:
	art = objekt.art
	groesse = objekt.groesse
	position = Iso.zu_punkt(Vector2(objekt.zelle) + Vector2(groesse - Vector2i.ONE) * 0.5)

	var pfad := BILDORDNER + art + ".png"
	if not BILDER.has(art) or not ResourceLoader.exists(pfad):
		return
	var lage: Dictionary = BILDER[art]
	var gespiegelt: bool = objekt.gespiegelt
	_bild = _baue_bild(load(pfad), lage, gespiegelt)
	if lage.get("wind", false):
		_bild.material = _hole_wind_stoff()
	add_child(_bild)

	if lage.has("licht"):
		var stelle: Vector2 = lage.licht
		_schein = Sprite2D.new()
		_schein.texture = _hole_lichtfleck()
		_schein.position = _bild.position + Vector2(-stelle.x if gespiegelt else stelle.x, stelle.y)
		var stoff := CanvasItemMaterial.new()
		stoff.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_schein.material = stoff
		_flackern = position.x * 0.05
		add_child(_schein)


## Schatten des Objekts als eigener Knoten für die Schattenebene. Null, wenn es keinen wirft.
func baue_schatten() -> Node2D:
	if _bild == null or art in Welt.FLACHE_ARTEN:
		return null
	var lage: Dictionary = BILDER[art]
	var schatten := Node2D.new()

	if lage.has("kasten"):
		schatten.position = position
		var kasten := Kastenschatten.new()
		kasten.groesse = groesse
		kasten.wandhoehe = lage.kasten.x
		kasten.firsthoehe = lage.kasten.y
		schatten.add_child(kasten)
		return schatten

	schatten.position = position + _bild.position
	# Weicher Fleck direkt am Fuß. Ohne ihn wirkt das Objekt, als schwebe es über dem Boden.
	var stand := Sprite2D.new()
	stand.texture = _hole_standfleck()
	stand.modulate = Kastenschatten.FARBE
	stand.scale = Vector2(1.0, 0.5) * (lage.stand * 2.0 / stand.texture.get_width())
	schatten.add_child(stand)

	var wurf := _bild.duplicate() as Sprite2D
	wurf.position = Vector2.ZERO
	wurf.material = _hole_schatten_stoff()
	schatten.add_child(wurf)
	return schatten


func _process(delta: float) -> void:
	if _schein == null:
		return
	_flackern += delta
	var unruhe := 0.88 + 0.08 * sin(_flackern * 9.0) + 0.04 * sin(_flackern * 23.0)
	_schein.modulate = Color(LICHTFARBE, 0.45 * licht * unruhe)
	_schein.scale = Vector2.ONE * (1.0 + 0.06 * sin(_flackern * 6.0))


func _draw() -> void:
	if _bild:
		return
	match art:
		"baum":
			_zeichne_baum()
		"stein":
			_zeichne_stein()
		"haus":
			_zeichne_haus()


## Bild mit dem Fußpunkt im Ursprung des Sprites, damit Spiegeln und Schatten daran ansetzen.
func _baue_bild(textur: Texture2D, lage: Dictionary, gespiegelt: bool) -> Sprite2D:
	var inhalt := textur.get_width() / (1.0 + 2.0 * RAND)
	var fuss: Vector2 = lage.fuss
	var anteil := 1.0 - fuss.x if gespiegelt else fuss.x
	var bild := Sprite2D.new()
	bild.texture = textur
	bild.centered = false
	bild.flip_h = gespiegelt
	bild.offset = -Vector2((RAND + anteil) * inhalt, fuss.y * textur.get_height())
	bild.scale = Vector2.ONE * (lage.breite / inhalt)
	bild.position = lage.get("versatz", Vector2.ZERO)
	return bild


## Gibt die gemeinsam genutzten Materialien frei. Beim Beenden nötig, sonst meldet Godot ein Leck.
static func raeume_auf() -> void:
	_wind_stoff = null
	_schatten_stoff = null
	_lichtfleck = null
	_standfleck = null


static func _hole_wind_stoff() -> ShaderMaterial:
	if _wind_stoff == null:
		_wind_stoff = ShaderMaterial.new()
		_wind_stoff.shader = preload("res://src/ansicht/shader/wind.gdshader")
	return _wind_stoff


static func _hole_schatten_stoff() -> ShaderMaterial:
	if _schatten_stoff == null:
		_schatten_stoff = ShaderMaterial.new()
		_schatten_stoff.shader = preload("res://src/ansicht/shader/schatten.gdshader")
	return _schatten_stoff


static func _hole_lichtfleck() -> GradientTexture2D:
	if _lichtfleck == null:
		_lichtfleck = _baue_fleck(0.0)
	return _lichtfleck


static func _hole_standfleck() -> GradientTexture2D:
	if _standfleck == null:
		_standfleck = _baue_fleck(0.6)
	return _standfleck


## Runder Fleck, der bis zum Anteil kern voll deckt und danach zum Rand hin ausläuft.
static func _baue_fleck(kern: float) -> GradientTexture2D:
	var verlauf := Gradient.new()
	verlauf.set_color(0, Color(1, 1, 1, 1))
	verlauf.set_color(1, Color(1, 1, 1, 0))
	if kern > 0.0:
		verlauf.add_point(kern, Color(1, 1, 1, 1))
	var fleck := GradientTexture2D.new()
	fleck.gradient = verlauf
	fleck.fill = GradientTexture2D.FILL_RADIAL
	fleck.fill_from = Vector2(0.5, 0.5)
	fleck.fill_to = Vector2(1.0, 0.5)
	fleck.width = 160
	fleck.height = 160
	return fleck


func _zeichne_schatten(radius: float) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO)


func _zeichne_baum() -> void:
	_zeichne_schatten(40.0)
	draw_rect(Rect2(-7, -52, 14, 54), Color("7a5a3c"))
	draw_circle(Vector2(-22, -76), 30.0, Color("4f8a55"))
	draw_circle(Vector2(24, -80), 28.0, Color("4f8a55"))
	draw_circle(Vector2(0, -98), 44.0, Color("5c9a5e"))
	draw_circle(Vector2(-10, -110), 22.0, Color("71ad6c"))


func _zeichne_stein() -> void:
	_zeichne_schatten(34.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-34, 0), Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(36, 2), Vector2(4, 12)]),
		Color("8d8f96")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(2, -12)]),
		Color("a9abb1")
	)


func _zeichne_haus() -> void:
	var halb := Vector2(groesse) * 0.5
	# Ecken der Grundfläche, relativ zur Mitte: hinten, rechts, vorne, links.
	var hinten := Iso.zu_punkt(Vector2(-halb.x, -halb.y))
	var rechts := Iso.zu_punkt(Vector2(halb.x, -halb.y))
	var vorne := Iso.zu_punkt(Vector2(halb.x, halb.y))
	var links := Iso.zu_punkt(Vector2(-halb.x, halb.y))
	var hoch := Vector2(0, -96)
	var first := (hinten + vorne) * 0.5 + hoch + Vector2(0, -78)

	draw_colored_polygon(PackedVector2Array([links, vorne, vorne + hoch, links + hoch]), Color("d9c7a6"))
	draw_colored_polygon(PackedVector2Array([vorne, rechts, rechts + hoch, vorne + hoch]), Color("efe0c1"))
	# Tür an der rechten Wand
	var tuer_a := vorne.lerp(rechts, 0.4)
	var tuer_b := vorne.lerp(rechts, 0.62)
	draw_colored_polygon(
		PackedVector2Array([tuer_a, tuer_b, tuer_b + Vector2(0, -58), tuer_a + Vector2(0, -58)]), Color("7a5a3c")
	)
	# Dach: erst die beiden hinteren Flächen, dann die vorderen
	draw_colored_polygon(PackedVector2Array([hinten + hoch, links + hoch, first]), Color("a8523f"))
	draw_colored_polygon(PackedVector2Array([hinten + hoch, rechts + hoch, first]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([links + hoch, vorne + hoch, first]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([vorne + hoch, rechts + hoch, first]), Color("c96a50"))
