extends BaseLevel

class_name LevelOne

## Level One — shallow waters.
## Basic fish everywhere, sharks only in the deep.

var basic_fish_scene: PackedScene = preload("uid://bunm3ffkiabq2")
var shark_scene: PackedScene = preload("uid://dhs6f6dnqp7vl")

func _get_entries() -> Array:
	return [
		{ "scene": basic_fish_scene, "weight": 10.0, "min_depth": 80.0 },
		{ "scene": shark_scene, "weight": 2.0, "min_depth": 1000.0 },
	]

func get_spawn_margin(scene: PackedScene) -> float:
	if scene == shark_scene:
		return 350.0
	return 150.0
