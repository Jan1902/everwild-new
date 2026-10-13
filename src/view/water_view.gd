class_name WaterView
extends Node2D
## What moves on the painted water of a world: the bare bed that comes out where the level has
## fallen, and above it the streaks of light on the water that is left. Both get the level from
## the mood of the world and find the water in the painted ground itself, so they follow its
## banks. They cover the water cells and the cells around them, because the painted water does
## not end exactly where the grid does.

var world: World


func _init(shown: World, sprites: Sprites) -> void:
	world = shown
	var ground_path: String = world.ground_image.get("path", "")
	var ground: Texture2D = load(ground_path) if not ground_path.is_empty() and ResourceLoader.exists(ground_path) else null
	for shader: Shader in [preload("res://src/view/shaders/water_bed.gdshader"), preload("res://src/view/shaders/water.gdshader")]:
		var layer := Node2D.new()
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		shader_material.set_shader_parameter("noise", sprites.water_noise())
		shader_material.set_shader_parameter("depth", sprites.water_depth(world))
		shader_material.set_shader_parameter("grid_size", Vector2(world.size))
		if ground:
			shader_material.set_shader_parameter("has_ground", true)
			shader_material.set_shader_parameter("ground", ground)
			shader_material.set_shader_parameter("ground_origin", Vector2(world.ground_image.origin[0], world.ground_image.origin[1]))
			shader_material.set_shader_parameter("ground_scale", world.ground_image.scale)
		layer.material = shader_material
		layer.draw.connect(_draw_cells.bind(layer, ground != null))
		add_child(layer)


func _draw_cells(layer: Node2D, around: bool) -> void:
	var half := Iso.CELL * 0.5
	for cell in _cells(around):
		var centre := Iso.to_point(Vector2(cell))
		layer.draw_colored_polygon(
			PackedVector2Array([
				centre + Vector2(0, -half.y), centre + Vector2(half.x, 0),
				centre + Vector2(0, half.y), centre + Vector2(-half.x, 0),
			]),
			Color.WHITE
		)


## The water cells, each of them once, and if asked for the cells around them as well.
func _cells(around: bool) -> Array[Vector2i]:
	var cells := {}
	for y in world.size.y:
		for x in world.size.x:
			if world.ground(Vector2i(x, y)) not in Sprites.WATER_GROUND:
				continue
			var reach := 1 if around else 0
			for dy in range(-reach, reach + 1):
				for dx in range(-reach, reach + 1):
					cells[Vector2i(x + dx, y + dy)] = true
	var list: Array[Vector2i] = []
	list.assign(cells.keys())
	return list
