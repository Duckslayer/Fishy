
shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.7, 0.3, 1.0);
uniform float glow_tip_bias : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Gradient: stronger toward the tip (bottom of sprite, UV.y = 1.0)
	float tip_factor = pow(UV.y, glow_tip_bias);
	
	// Additive glow on the sprite pixels only (use alpha to mask)
	vec3 glow = glow_color.rgb * tip_factor * glow_intensity * 2.0;
	COLOR = vec4(tex.rgb + glow, tex.a);
}
