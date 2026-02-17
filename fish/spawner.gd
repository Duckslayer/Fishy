extends Node2D

@export var fish_scenes : Array[PackedScene]
var number_of_fish = 4

func _process(delta: float) -> void:
	pass
	

func spawn_fish():
	var fish = fish_scenes.pick_random().instantiate()
	
	var spawn_pos = Vector2(global_position.x + randf_range(-1000, 1000), global_position.y + randf_range(1000, 2000))
	
	var spawn_right = spawn_pos[0] < global_position.x
	
	if not spawn_right:
		fish.scale.x = -fish.scale.x
	
	fish.global_position = spawn_pos
	
	#Surely this is clean!
	get_parent().get_parent().add_child(fish)

func _on_timer_timeout() -> void:
	for i in range(number_of_fish):
		spawn_fish() # Replace with function body.
