class_name Testhilfe
extends Node
## Steuert das laufende Spiel über Kommandozeilen-Argumente, um es automatisch zu prüfen.
##
##   godot --path . -- --tippe=16,9 --warte=6 --foto=C:/pfad/bild.png
##
## --tippe=x,y  tippt auf die Zelle (mehrfach möglich, nacheinander mit je --warte Sekunden Abstand)
## --warte=s    Wartezeit nach jedem Tippen, Standard 1
## --foto=pfad  speichert am Ende ein Bildschirmfoto
## --falsch     schaltet sofort auf die falsche Stimmung der Welt
## Danach werden die Zelle der Figur und der Stand der Musik ausgegeben und das Spiel beendet.


func _ready() -> void:
	var tipps: Array[Vector2i] = []
	var warte := 1.0
	var foto := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--tippe="):
			var teile := argument.trim_prefix("--tippe=").split(",")
			tipps.append(Vector2i(int(teile[0]), int(teile[1])))
		elif argument.begins_with("--warte="):
			warte = float(argument.trim_prefix("--warte="))
		elif argument.begins_with("--foto="):
			foto = argument.trim_prefix("--foto=")

	var spiel := get_parent()
	if "--falsch" in OS.get_cmdline_user_args():
		spiel.setze_falsch(true, true)
	await get_tree().create_timer(0.5).timeout
	for zelle in tipps:
		_tippe(spiel, zelle)
		await get_tree().create_timer(warte).timeout
	if tipps.is_empty():
		await get_tree().create_timer(warte).timeout

	if not foto.is_empty():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(foto)
	print("spieler=%d,%d musik=%.1f" % [spiel.spieler.zelle.x, spiel.spieler.zelle.y, spiel.musikstand()])
	# Die Musik muss ausgeklungen sein, bevor Godot schließt, sonst meldet es ein Leck.
	spiel.stoppe_musik()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


## Schickt eine echte Berührung an die Bildschirmstelle der Zelle, damit auch die Umrechnung geprüft wird.
func _tippe(spiel: Node2D, zelle: Vector2i) -> void:
	# Eingaben kommen in Fensterkoordinaten an, also vor der Skalierung auf die Basisauflösung.
	var stelle := get_viewport().get_final_transform() * spiel.get_canvas_transform() * Iso.zu_punkt(zelle)
	for gedrueckt: bool in [true, false]:
		var tipp := InputEventScreenTouch.new()
		tipp.position = stelle
		tipp.pressed = gedrueckt
		Input.parse_input_event(tipp)
