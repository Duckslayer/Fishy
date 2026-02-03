shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 0.5, 1.0, 1.0); // Surface blue
uniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 0.05, 1.0); // Abyss blue
uniform float harpoon_y = 0.0;
uniform float gradient_size = 0.5; // Controls how "stretched" the gradient is

void fragment() {
    // UV.y is 0.0 at the top of the ColorRect and 1.0 at the bottom.
    // We mix the pixel's local position with the harpoon's global position.
    float local_depth = SCREEN_UV.y;
    
    // This calculation ensures the top is always lighter than the bottom
    // but the whole thing shifts darker as harpoon_y increases.
    float gloom = clamp((harpoon_y * 0.0002) + (local_depth * gradient_size), 0.0, 1.0);
    
    COLOR = mix(top_color, bottom_color, gloom);
}