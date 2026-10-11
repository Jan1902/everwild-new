class_name WaterView
extends Node2D
## Lays moving streaks of light over all water cells of the world.

var world: World


func _ready() -> void:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	var texture := NoiseTexture2D.new()
	texture.noise = noise
	texture.seamless = true
	texture.width = 256
	texture.height = 256

	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://src/view/shaders/water.gdshader")
	shader_material.set_shader_parameter("noise", texture)
	material = shader_material


func _draw() -> void:
	var half := Iso.CELL * 0.5
	for y in world.size.y:
		for x in world.size.x:
			if world.ground(Vector2i(x, y)) in [World.Ground.WATER, World.Ground.BRIDGE]:
				var centre := Iso.to_point(Vector2(x, y))
				draw_colored_polygon(
					PackedVector2Array([
						centre + Vector2(0, -half.y), centre + Vector2(half.x, 0),
						centre + Vector2(0, half.y), centre + Vector2(-half.x, 0),
					]),
					Color.WHITE
				)
