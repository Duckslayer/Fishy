shader_type canvas_item;

uniform float wave_speed : hint_range(1.0, 10.0) = 3.0;
uniform float wave_amplitude : hint_range(1.0, 20.0) = 6.0;
uniform float wave_frequency : hint_range(1.0, 10.0) = 3.0;

void vertex() {
	// Tail is on the left (UV.x = 0), head on the right (UV.x = 1).
	// Invert UV.x so deformation is strongest at the tail.
	float tail_weight = pow(1.0 - UV.x, 2.0);
	float wave = sin(TIME * wave_speed + UV.x * wave_frequency) * wave_amplitude;
	VERTEX.y += wave * tail_weight;
}
