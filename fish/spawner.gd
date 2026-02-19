extends Node2D

@export var fish_scenes : Array[PackedScene]
var number_of_fish = 4

# Speed and size randomisation ranges
var speed_range := Vector2(0.6, 1.5)
var size_range := Vector2(0.7, 1.3)

func _process(delta: float) -> void:
	pass

func spawn_fish():
	var fish = fish_scenes.pick_random().instantiate()
	
	var spawn_pos = Vector2(global_position.x + randf_range(-1000, 1000), global_position.y + randf_range(1000, 2000))
	
	var spawn_right = spawn_pos[0] < global_position.x
	
	if not spawn_right:
		fish.scale.x = -fish.scale.x
	
	fish.global_position = spawn_pos
	_randomize_fish(fish)
	
	#Surely this is clean!
	get_parent().get_parent().add_child(fish)

func spawn_side_fish():
	var fish = fish_scenes.pick_random().instantiate()
	
	var camera = get_viewport().get_camera_2d()
	var cam_pos = camera.global_position
	var viewport_size = get_viewport_rect().size / camera.zoom
	var half_w = viewport_size.x / 2.0

	# Pick left or right side
	var spawn_right = randf() > 0.5
	var margin = randf_range(50, 300)
	var x: float
	if spawn_right:
		x = cam_pos.x + half_w + margin
	else:
		x = cam_pos.x - half_w - margin
		
	# Random depth below water surface (y = 0)
	var y = randf_range(100, 2000)
	
	fish.global_position = Vector2(x, y)
	
	# Face toward center of screen
	if spawn_right:
		fish.scale.x = -fish.scale.x
	
	_randomize_fish(fish)
	get_parent().get_parent().add_child(fish)

func _randomize_fish(fish):
	var speed_mult = randf_range(speed_range.x, speed_range.y)
	fish.speed = fish.speed * speed_mult
	
	var scale_mult = randf_range(size_range.x, size_range.y)
	fish.size_scale = scale_mult

func _on_timer_timeout() -> void:
	for i in range(number_of_fish):
		spawn_fish()
	
	# Also spawn fish swimming in from the sides
	for i in range(number_of_fish):
		spawn_side_fish()
