extends SceneTree
## Prüft die Spiellogik ohne Grafik.
##
##   godot --headless --path . --script tests/test_logik.gd

var _fehlschlaege := 0
var _pruefungen := 0


func _init() -> void:
	_teste_iso()
	_teste_dorf()
	print("%d Prüfungen, %d fehlgeschlagen" % [_pruefungen, _fehlschlaege])
	quit(1 if _fehlschlaege > 0 else 0)


func _pruefe(bedingung: bool, was: String) -> void:
	_pruefungen += 1
	if not bedingung:
		_fehlschlaege += 1
		print("FEHLER: " + was)


func _teste_iso() -> void:
	var stimmt := true
	for y in 20:
		for x in 20:
			var zelle := Vector2i(x, y)
			var mitte := Iso.zu_punkt(zelle)
			# Mitte und vier Punkte knapp innerhalb der Raute müssen dieselbe Zelle ergeben.
			for versatz: Vector2 in [Vector2.ZERO, Vector2(60, 0), Vector2(-60, 0), Vector2(0, 30), Vector2(0, -30)]:
				if Iso.zu_zelle(mitte + versatz) != zelle:
					stimmt = false
	_pruefe(stimmt, "Iso: Punkt und Zelle lassen sich nicht hin und zurück umrechnen")


func _teste_dorf() -> void:
	var welt := Welt.aus_datei("res://data/welten/dorf.json")
	_pruefe(welt.fehler().is_empty(), "Dorf hat Datenfehler: %s" % [welt.fehler()])
	_pruefe(welt.groesse == Vector2i(20, 20), "Dorf ist nicht 20x20")
	_pruefe(welt.spieler == welt.start, "Figur steht nicht auf der Startzelle")

	_pruefe(not welt.begehbar(Vector2i(0, 0)), "Leere ist begehbar")
	_pruefe(not welt.begehbar(Vector2i(13, 8)), "Wasser ist begehbar")
	_pruefe(welt.begehbar(Vector2i(13, 9)), "Brücke ist nicht begehbar")
	_pruefe(not welt.begehbar(Vector2i(8, 5)), "Haus ist begehbar")
	_pruefe(not welt.begehbar(Vector2i(9, 6)), "Zweite Zelle des Hauses ist begehbar")
	_pruefe(not welt.begehbar(Vector2i(7, 8)), "Laterne ist begehbar")
	_pruefe(not welt.begehbar(Vector2i(-1, 5)), "Zelle außerhalb des Rasters ist begehbar")

	var ziel := Vector2i(16, 9)
	var weg := welt.finde_weg(welt.start, ziel)
	_pruefe(not weg.is_empty(), "Kein Weg über den Bach")
	_pruefe(Vector2i(13, 9) in weg, "Weg über den Bach führt nicht über die Brücke")
	if not weg.is_empty():
		_pruefe(weg[0] == welt.start and weg[-1] == ziel, "Weg beginnt oder endet falsch")
	var lueckenlos := true
	for i in weg.size():
		if not welt.begehbar(weg[i]):
			lueckenlos = false
		if i > 0 and maxi(absi(weg[i].x - weg[i - 1].x), absi(weg[i].y - weg[i - 1].y)) != 1:
			lueckenlos = false
	_pruefe(lueckenlos, "Weg enthält Sprünge oder gesperrte Zellen")
	_pruefe(weg == welt.finde_weg(welt.start, ziel), "Wegfindung ist nicht deterministisch")

	_pruefe(welt.finde_weg(welt.start, Vector2i(13, 8)).is_empty(), "Weg ins Wasser gefunden")
	_pruefe(welt.finde_weg(welt.start, Vector2i(8, 5)).is_empty(), "Weg in ein Haus gefunden")

	_pruefe(not welt.setze_spieler(Vector2i(13, 8)), "Figur lässt sich ins Wasser setzen")
	_pruefe(welt.setze_spieler(ziel) and welt.spieler == ziel, "Figur lässt sich nicht versetzen")
