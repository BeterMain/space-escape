shader_type spatial;

uniform vec3 color = vec3(1.0, 1.0, 1.0);
uniform float rim = 1.0;
uniform float mettalic = 1.0;
uniform float roughness = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.x += sin(TIME * 5.0 + VERTEX.x * 10.0) * 0.03;
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 new_color = color;
	new_color.y = sin(TIME * 2.0);
	
	RIM = rim;
	METALLIC = mettalic;
	ROUGHNESS = roughness;
	ALBEDO = new_color;
}
