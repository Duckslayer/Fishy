extends Area2D

class_name BaseFish

@export var speed: float = 100.0
@export var size_scale: float = 1.0
@export var points: int = 10

var blood_burst_scene: PackedScene = preload("res://effects/blood_burst.tscn")

func die() -> void:
	# Disable collisions immediately so it can't be hit twice
	collision_layer = 0
	collision_mask = 0

	# Spawn blood burst at our position
	var blood := blood_burst_scene.instantiate()
	blood.global_position = global_position
	get_parent().add_child(blood)

	# Stop the swim animation if present
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()

	# Detach Appearance and send it to the harpoon for impaling
	var appearance := $Appearance
	remove_child(appearance)
	GameEvents.fish_impaled.emit(appearance)

	GameEvents.fish_kill.emit(points)
	queue_free()
