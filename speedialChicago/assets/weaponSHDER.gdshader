shader_type canvas_item;

uniform sampler2D noise_img;
uniform vec4 myColor : source_color;

void fragment() {
	vec2 uv1 = vec2(UV.x, UV.y);
	vec2 uv2 = vec2(UV.x, UV.y);
	vec2 uv3 = vec2(UV.x, UV.y);

	float noise_r = texture(noise_img, uv1).r;
	float noise_g = texture(noise_img, uv1).g;
	float noise_b = texture(noise_img, uv1).b;


	float newA = noise_r * noise_g * noise_b;

	COLOR.rgb = myColor.rgb;
	COLOR.a = newA * 10.0 * texture(TEXTURE, UV).a;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
