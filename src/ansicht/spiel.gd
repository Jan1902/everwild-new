extends Node2D
## Hauptszene: lädt eine Welt, baut ihre Ansicht auf und setzt Tippen in Bewegung um.

const WELT_PFAD := "res://data/welten/dorf.json"
const ZOOM := 1.5
const HIMMEL_OBEN := Color("9db7c9")
const HIMMEL_UNTEN := Color("f1dcc0")

var welt: Welt
var spieler: Spieler

var _marke: Zielmarke
var _kamera: Camera2D


func _ready() -> void:
	welt = Welt.aus_datei(WELT_PFAD)
	for meldung in welt.fehler():
		push_error(meldung)

	_baue_himmel()

	_baue_boden()

	# Flache Objekte wie die Brücke liegen direkt auf dem Boden, die Figur läuft immer darüber.
	var flach := Node2D.new()
	add_child(flach)

	_marke = Zielmarke.new()
	add_child(_marke)

	# Alle anderen Objekte und die Figur liegen in einer Ebene, die nach y sortiert:
	# was weiter vorne steht, verdeckt.
	var ebene := Node2D.new()
	ebene.y_sort_enabled = true
	add_child(ebene)
	for objekt in welt.objekte:
		var ansicht := ObjektAnsicht.new()
		ansicht.richte_ein(objekt)
		(flach if objekt.art in Welt.FLACHE_ARTEN else ebene).add_child(ansicht)

	spieler = Spieler.new()
	spieler.setze(welt.spieler)
	spieler.zelle_erreicht.connect(welt.setze_spieler)
	ebene.add_child(spieler)

	_kamera = Camera2D.new()
	_kamera.zoom = Vector2.ONE * ZOOM
	_kamera.position = _kameraziel()
	_kamera.position_smoothing_enabled = true
	add_child(_kamera)

	if not OS.get_cmdline_user_args().is_empty():
		add_child(Testhilfe.new())


func _process(_delta: float) -> void:
	_kamera.position = _kameraziel()


func _unhandled_input(ereignis: InputEvent) -> void:
	var tipp := ereignis as InputEventScreenTouch
	if tipp and tipp.pressed:
		gehe_zu(Iso.zu_zelle(get_canvas_transform().affine_inverse() * tipp.position))


## Schickt die Figur zu einer Zelle. Gibt false zurück, wenn es keinen Weg dorthin gibt.
func gehe_zu(zelle: Vector2i) -> bool:
	var weg := welt.finde_weg(spieler.naechster_halt(), zelle)
	if weg.is_empty():
		return false
	spieler.gehe(weg)
	_marke.zeige(zelle)
	return true


func _kameraziel() -> Vector2:
	return spieler.position + Vector2(0, -40)


## Nimmt das gemalte Bodenbild der Welt. Gibt es keines, wird der Boden als Platzhalter gezeichnet.
func _baue_boden() -> void:
	var pfad: String = welt.bodenbild.get("pfad", "")
	if pfad.is_empty() or not ResourceLoader.exists(pfad):
		var platzhalter := BodenAnsicht.new()
		platzhalter.welt = welt
		add_child(platzhalter)
		return
	var bild := Sprite2D.new()
	bild.texture = load(pfad)
	bild.centered = false
	bild.position = Vector2(welt.bodenbild.ursprung[0], welt.bodenbild.ursprung[1])
	bild.scale = Vector2.ONE / welt.bodenbild.massstab
	add_child(bild)


func _baue_himmel() -> void:
	var verlauf := Gradient.new()
	verlauf.set_color(0, HIMMEL_OBEN)
	verlauf.set_color(1, HIMMEL_UNTEN)
	var textur := GradientTexture2D.new()
	textur.gradient = verlauf
	textur.fill_from = Vector2(0, 0)
	textur.fill_to = Vector2(0, 1)

	var flaeche := TextureRect.new()
	flaeche.texture = textur
	flaeche.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flaeche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flaeche.set_anchors_preset(Control.PRESET_FULL_RECT)

	var ebene := CanvasLayer.new()
	ebene.layer = -1
	ebene.add_child(flaeche)
	add_child(ebene)
