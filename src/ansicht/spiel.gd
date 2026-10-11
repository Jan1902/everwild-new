extends Node2D
## Hauptszene: lädt eine Welt, baut ihre Ansicht auf und setzt Tippen in Bewegung um.

const WELT_PFAD := "res://data/welten/dorf.json"
const ZOOM := 1.5
const HIMMEL_OBEN := Color("9db7c9")
const HIMMEL_UNTEN := Color("f1dcc0")
const SCHATTEN_DECKKRAFT := 0.3
const MUSIK_LAUTSTAERKE := -6.0
## Sekunden, die der Wechsel zwischen heiler und falscher Stimmung dauert.
const WECHSELDAUER := 2.5

var welt: Welt
var spieler: Spieler
## Aktueller Stand zwischen heiler (0) und falscher (1) Stimmung.
var falschheit := 0.0:
	set(wert):
		falschheit = wert
		_wende_stimmung_an()

var _marke: Zielmarke
var _kamera: Camera2D
var _faerbung: ShaderMaterial
var _musik: AudioStreamPlayer
var _daempfer: AudioEffectLowPassFilter
var _wechsel: Tween
var _ist_falsch := false


func _ready() -> void:
	welt = Welt.aus_datei(WELT_PFAD)
	for meldung in welt.fehler():
		push_error(meldung)

	_baue_himmel()
	_baue_boden()

	var wasser := WasserAnsicht.new()
	wasser.welt = welt
	add_child(wasser)

	# Flache Objekte wie die Brücke liegen direkt auf dem Boden, die Figur läuft immer darüber.
	var flach := Node2D.new()
	add_child(flach)

	# Alle Schatten liegen gemeinsam auf dem Boden. Als Gruppe gezeichnet, werden sie dort,
	# wo sie sich überlappen, nicht dunkler.
	var schatten := CanvasGroup.new()
	schatten.fit_margin = 400.0
	schatten.clear_margin = 400.0
	schatten.self_modulate = Color(1, 1, 1, SCHATTEN_DECKKRAFT)
	add_child(schatten)

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
		var wurf := ansicht.baue_schatten()
		if wurf:
			schatten.add_child(wurf)

	spieler = Spieler.new()
	spieler.setze(welt.spieler)
	spieler.zelle_erreicht.connect(welt.setze_spieler)
	ebene.add_child(spieler)

	_kamera = Camera2D.new()
	_kamera.zoom = Vector2.ONE * ZOOM
	_kamera.position = _kameraziel()
	_kamera.position_smoothing_enabled = true
	add_child(_kamera)

	_baue_faerbung()
	_baue_musik()
	_wende_stimmung_an()

	if not OS.get_cmdline_user_args().is_empty():
		add_child(Testhilfe.new())


func _exit_tree() -> void:
	ObjektAnsicht.raeume_auf()


func stoppe_musik() -> void:
	if _musik:
		_musik.stop()
		_musik.stream = null


func _process(_delta: float) -> void:
	_kamera.position = _kameraziel()


func _unhandled_input(ereignis: InputEvent) -> void:
	var tipp := ereignis as InputEventScreenTouch
	if tipp and tipp.pressed:
		gehe_zu(Iso.zu_zelle(get_canvas_transform().affine_inverse() * tipp.position))
	# Vorläufig zum Ausprobieren: F wechselt zwischen heiler und falscher Stimmung.
	var taste := ereignis as InputEventKey
	if taste and taste.pressed and not taste.echo and taste.physical_keycode == KEY_F:
		setze_falsch(not _ist_falsch)


## Schickt die Figur zu einer Zelle. Gibt false zurück, wenn es keinen Weg dorthin gibt.
func gehe_zu(zelle: Vector2i) -> bool:
	var weg := welt.finde_weg(spieler.naechster_halt(), zelle)
	if weg.is_empty():
		return false
	spieler.gehe(weg)
	_marke.zeige(zelle)
	return true


## Blendet zur falschen oder zurück zur heilen Stimmung der Welt über.
func setze_falsch(an: bool, sofort := false) -> void:
	_ist_falsch = an
	if _wechsel:
		_wechsel.kill()
	var ziel := 1.0 if an else 0.0
	if sofort:
		falschheit = ziel
		return
	_wechsel = create_tween()
	_wechsel.tween_property(self, "falschheit", ziel, WECHSELDAUER).set_trans(Tween.TRANS_SINE)


## Sekunden, die das Musikstück schon läuft. -1 ohne Musik.
func musikstand() -> float:
	return _musik.get_playback_position() if _musik and _musik.playing else -1.0


func _wende_stimmung_an() -> void:
	var s := Stimmung.mische(welt.stimmung, welt.stimmung_falsch, falschheit)
	RenderingServer.global_shader_parameter_set(&"wind", s.wind)
	RenderingServer.global_shader_parameter_set(&"wasser", s.wasser)
	RenderingServer.global_shader_parameter_set(&"schatten", s.schatten)
	ObjektAnsicht.licht = s.licht
	ObjektAnsicht.schattenwurf = s.schatten
	if _faerbung:
		_faerbung.set_shader_parameter("saettigung", s.saettigung)
		_faerbung.set_shader_parameter("farbe", Vector3(s.farbe.r, s.farbe.g, s.farbe.b))
		_faerbung.set_shader_parameter("nebel", s.nebel)
	if _musik:
		_musik.pitch_scale = s.tonhoehe
		# Von offen (20 kHz) bis stark gedämpft (800 Hz), gleichmäßig nach Gehör verteilt.
		_daempfer.cutoff_hz = 20000.0 * pow(0.04, s.daempfung)


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


## Legt die Färbung der Stimmung über das fertige Bild von Himmel und Welt.
func _baue_faerbung() -> void:
	_faerbung = ShaderMaterial.new()
	_faerbung.shader = preload("res://src/ansicht/shader/stimmung.gdshader")

	var flaeche := ColorRect.new()
	flaeche.material = _faerbung
	flaeche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flaeche.set_anchors_preset(Control.PRESET_FULL_RECT)

	var ebene := CanvasLayer.new()
	ebene.layer = 10
	ebene.add_child(flaeche)
	add_child(ebene)


func _baue_musik() -> void:
	if welt.musik.is_empty() or not ResourceLoader.exists(welt.musik):
		return
	var stueck: AudioStream = load(welt.musik)
	if stueck is AudioStreamMP3:
		stueck.loop = true

	# Eigener Kanal für die Musik, damit die Dämpfung keine anderen Klänge trifft.
	var kanal := AudioServer.bus_count
	AudioServer.add_bus(kanal)
	AudioServer.set_bus_name(kanal, "Musik")
	_daempfer = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(kanal, _daempfer)

	_musik = AudioStreamPlayer.new()
	_musik.stream = stueck
	_musik.bus = "Musik"
	_musik.volume_db = -40.0
	add_child(_musik)
	_musik.play()
	create_tween().tween_property(_musik, "volume_db", MUSIK_LAUTSTAERKE, 3.0)
