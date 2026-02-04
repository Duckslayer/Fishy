extends CharacterBody2D

@export var sea_level_y: float = 0.0
@export var wave_frequency: float = 10.0
@export var wave_speed: float = 1.0
@export var wave_amplitude: float = 0.01 # This should match your shader!

func _process(delta: float):
	# 1. Get the screen-width relative X position (0.0 to 1.0)
	var viewport_width = get_viewport_rect().size.x
	var screen_x = fmod(global_position.x, viewport_width) / viewport_width
	
	# 2. Mirror the shader's wave math
	var time = Time.get_ticks_msec() / 1000.0
	var w1 = sin(screen_x * wave_frequency + time * wave_speed)
	var w2 = sin(screen_x * wave_frequency * 2.1 + time * wave_speed * 1.5)
	var combined_wave = (w1 + (w2 * 0.5)) / 1.5
	
	# Convert the 0-1 wave amplitude back into world pixels
	var viewport_height = get_viewport_rect().size.y
	var wave_height_px = combined_wave * wave_amplitude * viewport_height
	
	# 3. Apply to the Boat
	global_position.y = sea_level_y + wave_height_px
	
	# Optional: Add a little tilt
	rotation = combined_wave * 0.1
