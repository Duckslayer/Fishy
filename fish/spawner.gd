extends Node2D

@export var fish_scenes: Array[PackedScene]
@export var number_of_fish: int = 8
@export var speed_range: Vector2 = Vector2(0.6, 1.5)
@export var size_range: Vector2 = Vector2(0.7, 1.3)
@export var min_depth: float = 100.0
@export var spawn_root: Node

var basic_fish = preload("uid://bunm3ffkiabq2")
var shark = preload("uid://dhs6f6dnqp7vl")

var fish_deck: Array[Resource]

func _ready() -> void:
	fish_deck.append(basic_fish)

func spawn_fish() -> void:
	
	var fish: BaseFish = draw_fish()

	var camera := get_viewport().get_camera_2d()
	var cam_pos := camera.global_position
	var viewport_size := get_viewport_rect().size / camera.zoom
	var half_w := viewport_size.x / 2.0
	var half_h := viewport_size.y / 2.0

	# Randomly pick a spawn zone: left, right, or below
	var zone := randi() % 3
	var x: float
	var y: float
	var facing_right: bool

	match zone:
		0: # Left side
			x = cam_pos.x - half_w - randf_range(50, 300)
			y = max(0.0, cam_pos.y - half_h) + randf_range(100, half_h * 2.0)
			facing_right = true
		1: # Right side
			x = cam_pos.x + half_w + randf_range(50, 300)
			y = max(0.0, cam_pos.y - half_h) + randf_range(100, half_h * 2.0)
			facing_right = false
		2: # Below
			x = cam_pos.x + randf_range(-half_w, half_w)
			y = cam_pos.y + half_h + randf_range(200, 800)
			facing_right = randf() > 0.5

	# Never spawn above the water surface
	y = max(y, min_depth)

	fish.global_position = Vector2(x, y)

	if not facing_right:
		fish.scale.x = -fish.scale.x

	# Randomise speed and size
	fish.speed *= randf_range(speed_range.x, speed_range.y)
	fish.size_scale = randf_range(size_range.x, size_range.y)

	var root := spawn_root if spawn_root else get_parent().get_parent()
	root.add_child(fish)
	
func draw_fish() -> BaseFish:
	if get_depth() < 1000:
		return basic_fish.instantiate()
		
	return shark.instantiate()
	
func get_depth() -> int:
	var camera := get_viewport().get_camera_2d()
	var cam_pos := camera.global_position
	return cam_pos.y

func _on_timer_timeout() -> void:
	for i in range(number_of_fish):
		spawn_fish()
