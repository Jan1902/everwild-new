shader_type canvas_item;
// Shadow of a flat, upright object that stands along one of the two ground axes, such as an
// arch or a gate. Its image shows it at an angle, so every point of the image is first put back
// to where it stands on the ground and how high it is, and from there it is cast onto the ground.

// Shadow cast in the ground plane, seen from above (see mood.gd).
global uniform vec2 shadow;
// 1 for an object running from the upper left to the lower right, -1 for the mirrored one.
uniform float axis = 1.0;

void vertex() {
	// The vertex is given relative to the foot of the object. Along a ground axis, one step to
	// the right goes half a step down (or up, mirrored). What is left over is height.
	float along = VERTEX.x;
	float height = axis * 0.5 * along - VERTEX.y;
	vec2 on_ground = vec2(along, axis * along) + height * shadow;
	VERTEX = vec2(on_ground.x, on_ground.y * 0.5);
}

void fragment() {
	COLOR = vec4(0.08, 0.1, 0.22, texture(TEXTURE, UV).a);
}