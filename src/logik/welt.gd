class_name Welt
extends RefCounted
## Eine Welt als reine Daten: Bodenraster, Objekte, Position der Spielfigur.
## Kennt kein Rendering und läuft deshalb auch ohne Grafik.

enum Boden { LEERE, GRAS, WEG, WASSER, BRUECKE }

## Zeichen, mit denen der Boden in den Weltdateien geschrieben wird.
const ZEICHEN := {
	" ": Boden.LEERE,
	".": Boden.GRAS,
	"=": Boden.WEG,
	"~": Boden.WASSER,
	"#": Boden.BRUECKE,
}
const BEGEHBAR := [Boden.GRAS, Boden.WEG, Boden.BRUECKE]

var titel := ""
var groesse := Vector2i.ZERO
var start := Vector2i.ZERO
var spieler := Vector2i.ZERO
## Einträge mit "art" (String), "zelle" (Vector2i, hintere Ecke) und "groesse" (Vector2i).
var objekte: Array[Dictionary] = []

var _boden := PackedInt32Array()
var _belegt := {}
var _wege := AStarGrid2D.new()
var _fehler: Array[String] = []


static func aus_datei(pfad: String) -> Welt:
	var daten: Variant = JSON.parse_string(FileAccess.get_file_as_string(pfad))
	if not daten is Dictionary:
		var leer := Welt.new()
		leer._fehler.append("Weltdatei nicht lesbar: " + pfad)
		return leer
	return aus_daten(daten)


static func aus_daten(daten: Dictionary) -> Welt:
	var welt := Welt.new()
	welt.titel = daten.get("titel", "")
	welt.groesse = _zu_zelle(daten.get("groesse", [0, 0]))
	welt.start = _zu_zelle(daten.get("start", [0, 0]))
	welt.spieler = welt.start
	welt._lies_boden(daten.get("boden", []))
	for eintrag: Dictionary in daten.get("objekte", []):
		welt.objekte.append({
			"art": eintrag.get("art", ""),
			"zelle": _zu_zelle(eintrag.get("zelle", [0, 0])),
			"groesse": _zu_zelle(eintrag.get("groesse", [1, 1])),
		})
	welt._baue_wege()
	return welt


## Probleme in den Weltdaten. Eine leere Liste heißt: die Welt ist in Ordnung.
func fehler() -> Array[String]:
	var liste := _fehler.duplicate()
	if not begehbar(start):
		liste.append("Startzelle %s ist nicht begehbar" % start)
	for objekt in objekte:
		for zelle in belegte_zellen(objekt):
			if boden(zelle) != Boden.GRAS:
				liste.append("Objekt '%s' steht bei %s nicht auf Gras" % [objekt.art, zelle])
	return liste


func boden(zelle: Vector2i) -> Boden:
	if not Rect2i(Vector2i.ZERO, groesse).has_point(zelle):
		return Boden.LEERE
	return _boden[zelle.y * groesse.x + zelle.x] as Boden


func begehbar(zelle: Vector2i) -> bool:
	return boden(zelle) in BEGEHBAR and not _belegt.has(zelle)


func belegte_zellen(objekt: Dictionary) -> Array[Vector2i]:
	var zellen: Array[Vector2i] = []
	for y in objekt.groesse.y:
		for x in objekt.groesse.x:
			zellen.append(objekt.zelle + Vector2i(x, y))
	return zellen


## Kürzester Weg einschließlich Start- und Zielzelle. Leer, wenn es keinen gibt.
func finde_weg(von: Vector2i, nach: Vector2i) -> Array[Vector2i]:
	if not begehbar(von) or not begehbar(nach):
		return []
	return _wege.get_id_path(von, nach)


## Setzt die Spielfigur auf eine Zelle. Gibt false zurück, wenn sie dort nicht stehen kann.
func setze_spieler(zelle: Vector2i) -> bool:
	if not begehbar(zelle):
		return false
	spieler = zelle
	return true


func _lies_boden(zeilen: Array) -> void:
	_boden.resize(groesse.x * groesse.y)
	if zeilen.size() != groesse.y:
		_fehler.append("Boden hat %d Zeilen, erwartet %d" % [zeilen.size(), groesse.y])
	for y in groesse.y:
		var zeile: String = zeilen[y] if y < zeilen.size() else ""
		if zeile.length() != groesse.x:
			_fehler.append("Bodenzeile %d hat %d Zeichen, erwartet %d" % [y, zeile.length(), groesse.x])
		for x in groesse.x:
			var zeichen := zeile[x] if x < zeile.length() else " "
			if not ZEICHEN.has(zeichen):
				_fehler.append("Unbekanntes Bodenzeichen '%s' bei %s" % [zeichen, Vector2i(x, y)])
			_boden[y * groesse.x + x] = ZEICHEN.get(zeichen, Boden.LEERE)


func _baue_wege() -> void:
	for objekt in objekte:
		for zelle in belegte_zellen(objekt):
			_belegt[zelle] = true
	_wege.region = Rect2i(Vector2i.ZERO, groesse)
	_wege.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_wege.update()
	for y in groesse.y:
		for x in groesse.x:
			if not begehbar(Vector2i(x, y)):
				_wege.set_point_solid(Vector2i(x, y), true)


static func _zu_zelle(paar: Array) -> Vector2i:
	return Vector2i(int(paar[0]), int(paar[1]))
