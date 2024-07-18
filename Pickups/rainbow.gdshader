shader_type spatial;

uniform sampler2D question_texture : hint_default_transparent;
uniform vec2 uv1_scale = vec2(1.0, 1.0);
uniform float alpha = 0.5;
uniform bool rippliing = false;
uniform bool using_texture = false;
uniform vec3 head_color = vec3(1.0, 0.5, 0.0);
uniform vec3 face_color = vec3(0.0, 1.0, 1.0);

void vertex() {
	if (rippliing) {
		VERTEX.x += sin(TIME * 5.0 + VERTEX.x * 10.0) * 0.2;
		VERTEX.y += sin(TIME * 5.0 + VERTEX.x * 10.0) * 0.2;
	}
}

void fragment() {
	// Scale the UV1 coordinates
    vec2 scaled_uv1 = UV * uv1_scale;
	
	// Alter color on shader to make rainbow
	vec3 wave_color;
	wave_color.r = (sin(TIME * 5.0)  + 1.0) * 0.5;
	wave_color.g = (sin(TIME * 6.0)  + 1.0) * 0.5;
	wave_color.b = (sin(TIME * 7.0)  + 1.0) * 0.5;
	
	vec3 texture_color = ALBEDO;
	if (using_texture){
		texture_color = texture(question_texture, scaled_uv1).rgb;
	}
	
	vec3 out_color = texture_color.r * head_color + texture_color.g * wave_color;
	ALBEDO = out_color;
	ALPHA = alpha;
}
