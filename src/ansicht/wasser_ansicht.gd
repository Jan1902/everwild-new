class_name WasserAnsicht
extends Node2D
## Legt bewegte Lichtstreifen über alle Wasserzellen der Welt.

var welt: Welt


func _ready() -> void:
	var rauschen := FastNoiseLite.new()
	rauschen.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rauschen.frequency = 0.02
	var textur := NoiseTexture2D.new()
	textur.noise = rauschen
	textur.seamless = true
	textur.width = 256
	textur.height = 256

	var stoff := ShaderMaterial.new()
	stoff.shader = preload("res://src/ansicht/shader/wasser.gdshader")
	stoff.set_shader_parameter("rauschen", textur)
	material = stoff


func _draw() -> void:
	var halb := Iso.ZELLE * 0.5
	for y in welt.groesse.y:
		for x in welt.groesse.x:
			if welt.boden(Vector2i(x, y)) in [Welt.Boden.WASSER, Welt.Boden.BRUECKE]:
				var mitte := Iso.zu_punkt(Vector2(x, y))
				draw_colored_polygon(
					PackedVector2Array([
						mitte + Vector2(0, -halb.y), mitte + Vector2(halb.x, 0),
						mitte + Vector2(0, halb.y), mitte + Vector2(-halb.x, 0),
					]),
					Color.WHITE
				)
