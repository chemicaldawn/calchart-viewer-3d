shader_type spatial;

uniform vec3 line_color;
uniform vec3 field_color;

uniform sampler2D field;
uniform sampler2D grass;
uniform sampler2D noisemap;

void fragment() {
	ALBEDO = texture(field,UV).rgb;
	
	if(ALBEDO.r > 0.4) {
		ALBEDO = line_color;
	}
	else {
		ALBEDO = field_color - texture(noisemap,UV).rgb*0.06;
	}
	
	vec3 grass_difference = texture(grass, vec2(UV.x*50.0,UV.y*25.0)).rgb*0.2;
	
	ALBEDO -= grass_difference;}
