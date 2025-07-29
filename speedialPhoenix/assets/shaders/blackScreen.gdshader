shader_type canvas_item;

uniform vec4 myColor : source_color;
uniform float myOpaq = 1.0;

void fragment() {

	COLOR.rgb = myColor.rgb;
	COLOR.a = myOpaq;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
