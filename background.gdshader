shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 0.4, 0.6, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.05, 0.1, 1.0); // Darker base
uniform float wave_amplitude = 0.02;
uniform float wave_frequency = 20.0;
uniform float wave_speed = 1.0;

uniform float surface_level : hint_range(-1.5, 1.5) = 0.0;
// global_depth: 0.0 at sea level, 1.0 at the "bottom" of your world
uniform float global_depth : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float current_surface_y = surface_level + wave;

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
    
    COLOR = final_color;
}