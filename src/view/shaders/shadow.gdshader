shader_type canvas_item;
// Lays the silhouette of an object flat on the ground as its shadow. The foot point of the image
// must sit at the origin.
//
// "shadow" is the shadow cast in the ground plane, seen from above: direction and length per unit
// of object height. The image's height runs along that direction, its width across it. Finally
// everything is squashed to half height, like any circle on the ground of the world.

global uniform vec2 shadow;

void vertex() {
	float width = VERTEX.x;
	float height = -VERTEX.y;
	vec2 across = normalize(vec2(-shadow.y, shadow.x));
	vec2 on_ground = width * across + height * shadow;
	VERTEX = vec2(on_ground.x, on_ground.y * 0.5);
}

void fragment() {
	COLOR = vec4(0.08, 0.1, 0.22, texture(TEXTURE, UV).a);
}
