shader_type canvas_item;
uniform sampler2D dissolveNoise;
uniform float dissolved = 3.4;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	float noise = texture(dissolveNoise, UV).r;
	float showing_threshold = 0.3;
	COLOR.a *= step(sin(dissolved) * (UV.x + .9), noise - showing_threshold);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
