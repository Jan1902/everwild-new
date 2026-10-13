// How much of the bed of the water lies bare at a point of the world, shared by the shaders
// that paint the bed and the light on the water.
//
// Where the water is comes from the painted ground itself: its blue is the water, so bed and
// light follow the painted banks instead of the straight lines of the grid.
//
// "depth" holds, for every point of the water, how far it is from the nearest bank, in cells
// (see Sprites.water_depth). As the level falls, the bed comes out from the banks inwards: a
// narrow brook runs dry long before the middle of a pond does.

// Level of the water from the mood of the world: 1 is full, 0 is dry.
global uniform float water_level;
uniform sampler2D depth : filter_linear, repeat_disable;
uniform sampler2D noise : repeat_enable, filter_linear;
// Size of the world in cells.
uniform vec2 grid_size;
// The painted ground: its image, the point of the world at its upper left corner and image
// pixels per pixel of the world. Without one, the water is where the grid says.
uniform sampler2D ground : filter_linear, repeat_disable;
uniform bool has_ground = false;
uniform vec2 ground_origin;
uniform float ground_scale = 1.0;

// Cells from the bank that the depth texture can tell apart, and cells the bare bed reaches in
// from the bank when the water is gone.
const float DEPTH_RANGE = 3.0;
const float REACH = 2.2;

// Cells between the point and the nearest bank, by the grid.
float bank_distance(vec2 world_pos) {
	// The reverse of Iso.to_point for cells of 128 by 64.
	vec2 cell = vec2(world_pos.x / 64.0 + world_pos.y / 32.0, world_pos.y / 32.0 - world_pos.x / 64.0) * 0.5;
	return texture(depth, (cell + 0.5) / grid_size).r * DEPTH_RANGE;
}

// 1 where the ground is painted as water, 0 where it is anything else.
float painted_water(vec2 world_pos) {
	if (!has_ground) {
		return step(0.001, bank_distance(world_pos));
	}
	vec4 paint = texture(ground, (world_pos - ground_origin) * ground_scale / vec2(textureSize(ground, 0)));
	// Water is the only thing painted bluer than it is red or green; grey stone is neither.
	// Beyond the edge of the piece nothing is painted at all.
	float blue = smoothstep(-0.12, -0.02, paint.b - max(paint.r, paint.g)) * smoothstep(0.08, 0.2, paint.b - paint.r);
	return blue * smoothstep(0.5, 0.9, paint.a);
}

// Cells the bare bed reaches in from the bank at the current level.
float bed_reach() {
	return (1.0 - water_level) * REACH;
}

// 1 where the bed lies bare, 0 where there is water. The waterline is a little ragged.
float bed_cover(vec2 world_pos) {
	float ragged = (texture(noise, world_pos * 0.004).r - 0.5) * 0.25;
	float bare = 1.0 - smoothstep(bed_reach() - 0.12, bed_reach() + 0.04, bank_distance(world_pos) + ragged);
	return bare * smoothstep(0.0, 0.08, 1.0 - water_level);
}
