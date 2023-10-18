shader_type canvas_item;

void fragment() {
	if(sqrt(pow(0.5-UV.x,2)+pow(0.5-UV.y,2)) > 0.4) {
		COLOR = vec4(0,0,0,0);
	}
}
