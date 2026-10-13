shader_type canvas_item;
// Paints the bare bed over the painted water where the level has fallen: sand strewn with
// pebbles, darker and damp towards the water that is left. Under the far bank lies its shadow,
// so the bed reads as lying lower than the grass.

#include "water_bed.gdshaderinc"

const vec3 SAND = vec3(0.66, 0.56, 0.4);
const vec3 DAMP = vec3(0.38, 0.32, 0.25);
const vec3 PEBBLE = vec3(0.8, 0.78, 0.72);
const vec3 PEBBLE_DARK = vec3(0.42, 0.38, 0.33);
// How far below the far bank its shadow reaches, in pixels of the world, and how dark it is.
const float BANK_SHADOW = 20.0;
const float BANK_SHADOW_DEPTH = 0.42;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float grain = texture(noise, world_pos * 0.011).r;
	float damp = smoothstep(bed_reach() - 0.7, bed_reach(), bank_distance(world_pos));
	vec3 color = mix(SAND, DAMP, damp) * (0.9 + 0.2 * grain);

	// A few pebbles: pale and dark spots, from the same noise at a finer scale.
	float pale = texture(noise, world_pos * 0.019).r;
	float dark = texture(noise, world_pos * 0.016 + 0.31).r;
	color = mix(color, PEBBLE * (0.85 + 0.15 * grain), smoothstep(0.7, 0.74, pale) * 0.6 * (1.0 - 0.5 * damp));
	color = mix(color, PEBBLE_DARK, smoothstep(0.72, 0.76, dark) * 0.4);

	// Whatever lies up the screen from here and is not water is the far bank. Close below it
	// the bed is in its shadow.
	float near_bank = 1.0 - painted_water(world_pos - vec2(0.0, BANK_SHADOW * 0.4));
	float far_bank = 1.0 - painted_water(world_pos - vec2(0.0, BANK_SHADOW));
	color *= 1.0 - BANK_SHADOW_DEPTH * (0.6 * near_bank + 0.4 * far_bank);

	COLOR = vec4(color, bed_cover(world_pos) * painted_water(world_pos));
}
