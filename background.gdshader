shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 0.4, 0.6, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.05, 0.1, 1.0); // Darker base
uniform float wave_amplitude = 0.02;
uniform float wave_frequency = 10.0;
uniform float wave_speed = 1.0;

uniform float surface_level : hint_range(-1.5, 1.5) = 0.0;
// global_depth: 0.0 at sea level, 1.0 at the "bottom" of your world
uniform float global_depth : hint_range(0.0, 1.0) = 0.0;
uniform float wave_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float wave_steepness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // Multi-layered sine waves for a "choppy" look
    float w1 = sin(UV.x * wave_frequency + TIME * wave_speed);
    float w2 = sin(UV.x * wave_frequency * 2.1 + TIME * wave_speed * 1.5);
    
    // Combine and apply steepness (raising to a power sharpens the peaks)
    float combined_wave = (w1 + (w2 * 0.5)) / 1.5;
    float final_wave = pow(abs(combined_wave), wave_steepness) * sign(combined_wave);
    
    // Apply intensity and amplitude
    float wave_offset = final_wave * wave_amplitude * wave_intensity;
    float current_surface_y = surface_level + wave_offset;

    if (UV.y < current_surface_y) {
        discard;
    }

    // 1. Local Gradient (0.0 at surface, 1.0 at bottom of screen)
    float local_v = (UV.y - current_surface_y) / (1.0 - current_surface_y);
    local_v = clamp(local_v, 0.0, 1.0);
    
    // 2. Base Color Mix
    vec4 water_color = mix(top_color, bottom_color, local_v);
    
    // 3. Global Darkening
    // As global_depth increases, we mix the water_color with pure black.
    // We use a power function (pow) to make the darkening feel more "weighty"
    float darkness = pow(global_depth, 1.5); 
    vec4 final_color = mix(water_color, vec4(0.0, 0.0, 0.0, 1.0), darkness);
	
	// Foam logic
	float edge_dist = UV.y - current_surface_y;
	if (edge_dist < 0.01) { // 0.01 is the thickness of the foam
	    final_color = mix(vec4(0.7, 0.7, 1.0, 1.0), final_color, edge_dist * 100.0);
	}
    
    COLOR = final_color;
}