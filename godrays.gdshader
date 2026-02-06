shader_type canvas_item;

global uniform float wave_time;
uniform vec4 ray_color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float ray_count = 12.0;

// Function to generate pseudo-random noise for the rays
float noise(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

void fragment() {
    // 1. Create vertical streaks
    float streaks = sin(UV.x * ray_count + wave_time * 0.5);
    streaks += sin(UV.x * ray_count * 2.1 - wave_time * 0.3) * 0.5;

    // 2. Fade them out as they go down (depth)
    float vertical_fade = 1.0 - UV.y;

    // 3. Add some "shimmer"
    float shimmer = noise(UV.x + wave_time * 0.1);

    float final_rays = clamp(streaks, 0.0, 1.0) * vertical_fade * shimmer;

    COLOR = vec4(ray_color.rgb, final_rays * ray_color.a);
}