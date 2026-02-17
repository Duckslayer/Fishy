extends Node2D

@export var fish_scenes : Array[PackedScene]

func _process(delta: float) -> void:
	var current_depth = global_position.y
	

func spawn_fish():
	pass


func _on_timer_timeout() -> void:
	spawn_fish() # Replace with function body.
