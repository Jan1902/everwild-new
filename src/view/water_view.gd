class_name WaterView
extends Node2D
## Lays moving streaks of light over all water cells of the world.

var world: World


func _init(shown: World, sprites: Sprites) -> void:
	world = shown
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://src/view/shaders/water.gdshader")
	shader_material.set_shader_parameter("noise", sprites.water_noise())
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
