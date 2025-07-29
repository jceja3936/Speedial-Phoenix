shader_type canvas_item;

uniform sampler2D noise_img : repeat_enable;
uniform vec4 myColor : source_color;
uniform float myOpaq = 0.0;

void fragment() {
	vec2 uv1 = vec2(UV.x + TIME * .1, UV.y);
	vec2 uv2 = vec2(UV.x - TIME * .5, UV.y);
	vec2 uv3 = vec2(UV.x, UV.y + TIME * .1);

	float noise_r = texture(noise_img, uv1).r;
	float noise_g = texture(noise_img, uv2).g;
	float noise_b = texture(noise_img, uv3).b;


	float newA = noise_r * noise_g * noise_b;

	COLOR.rgb = myColor.rgb;
	COLOR.a = newA * myOpaq * texture(TEXTURE, UV).a;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
