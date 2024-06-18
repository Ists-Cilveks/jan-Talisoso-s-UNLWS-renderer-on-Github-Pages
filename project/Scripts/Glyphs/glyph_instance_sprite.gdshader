shader_type canvas_item;

uniform float difference: hint_range(0.0, 1.0) = 0.0;
const vec3 selection_color = vec3(0.05, 0.1, 0.4);

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(TEXTURE, UV);
    COLOR.rgb = tex.rgb * vec3(1.0-difference) + selection_color * vec3(difference);
	//COLOR.rgb = vec3(difference);
    COLOR.a = tex.a;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
