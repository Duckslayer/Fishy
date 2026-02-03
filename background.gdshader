shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 0.5, 1.0, 1.0); // Light blue
uniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 0.2, 1.0); // Deep dark blue
uniform float harpoon_y = 0.0; // The Y position of your harpoon

void fragment() {
    // This creates a vertical gradient based on the screen UV
    // We can shift the gradient intensity based on how far down we are
    float depth = UV.y + (harpoon_y * 0.0001); 
    COLOR = mix(top_color, bottom_color, clamp(depth, 0.0, 1.0));
}