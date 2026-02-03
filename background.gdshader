shader_type canvas_item;

// Colors
uniform vec4 top_color : source_color = vec4(0.0, 0.4, 0.6, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.1, 0.2, 1.0);

// Wave Settings
uniform float wave_amplitude = 0.03; // Height of waves
uniform float wave_frequency = 10.0; // How many waves across screen
uniform float wave_speed = 0.7;

// Depth Control
// 0.5 = Water line is in the middle of screen
// -0.1 = Water line is above the screen (Fully underwater)
uniform float surface_level : hint_range(-0.5, 1.5) = 0.5;

void fragment() {
    // 1. Calculate the wave offset using a sine function
    // We use UV.x to vary height across the width, and TIME to animate
    float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    
    // 2. Determine the actual Y position of the surface at this X coordinate
    float current_surface_y = surface_level + wave;

    // 3. The Cutoff Logic
    // If the current pixel is ABOVE the surface (lower UV.y value), we discard it.
    // This makes the pixel transparent, revealing the Sky ColorRect behind it.
    if (UV.y < current_surface_y) {
        discard;
    }
    
    // 4. Gradient Logic (Existing logic)
    // We remap UV.y so the gradient starts at the surface, not the screen top
    float depth_gradient = (UV.y - current_surface_y) / (1.0 - current_surface_y);
    depth_gradient = clamp(depth_gradient, 0.0, 1.0);
    
    COLOR = mix(top_color, bottom_color, depth_gradient);
}