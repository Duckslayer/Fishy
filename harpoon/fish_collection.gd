extends Node

## Manages impaled fish appearances and dangling physics fish on the harpoon.

var dangling_fish_scene: PackedScene = preload("res://fish/dangling_fish.tscn")
var fish_head: PackedScene = preload("uid://cgwuvoem13jj0")

# Track the tween appearances (temporary) and the dangling bodies (persistent)
var impaled_fish: Array[Node2D] = []
var dangling_fish: Array[Node] = []  # RigidBody2D + PinJoint2D instances
var tier: int = 0

@onready var harpoon: CharacterBody2D = get_parent()

func _ready() -> void:
	GameEvents.fish_impaled.connect(_on_fish_impaled)
	GameEvents.tier_changed.connect(_on_tier_changed)


func _on_fish_impaled(appearance: Node2D) -> void:
	# Adopt the fish's visual as a child of the harpoon
	# Here we can do some tinkering with different fish visuals
	var damaged_appearance = damage_fish_appearance(appearance)
	
	harpoon.add_child(damaged_appearance)
	# Random offset near the harpoon tip so multiple fish don't perfectly overlap
	damaged_appearance.position = %CollisionPolygon2D.position + Vector2(randf_range(-8, 8), randf_range(-5, 15))
	damaged_appearance.rotation = randf_range(-0.3, 0.3)
	impaled_fish.append(damaged_appearance)

	var fish_length: float = damaged_appearance.get_node("Body").texture.get_width() * damaged_appearance.scale.x
	var direction: Vector2 = (%RopeMarker.position - damaged_appearance.position).normalized()

	# Slide to rope marker and fade out
	var tween := harpoon.create_tween()
	tween.set_parallel(true)
	tween.tween_property(damaged_appearance, "position", %RopeMarker.position + (direction * fish_length * 0.4), 0.2)
	tween.tween_property(damaged_appearance, "rotation", PI / 2, 0.2)

	tween.finished.connect(func() -> void:
		if is_instance_valid(damaged_appearance):
			_spawn_dangling_fish(damaged_appearance)
			damaged_appearance.queue_free()
			impaled_fish.erase(damaged_appearance)
	)

func _spawn_dangling_fish(appearance: Node2D) -> void:
	var fish_body: RigidBody2D = dangling_fish_scene.instantiate()
	fish_body.setup(appearance)

	var fish_length: float = appearance.get_node("Body").texture.get_width() * appearance.scale.x
	var direction: Vector2 = (appearance.position - %RopeMarker.position).normalized()

	# Add as child of the harpoon so it moves with us
	harpoon.add_child(fish_body)
	fish_body.position = %RopeMarker.position + (direction * fish_length * 0.4)
	fish_body.rotation = appearance.rotation

	# Create a PinJoint2D to attach at the rope marker
	var pin := PinJoint2D.new()
	harpoon.add_child(pin)
	pin.position = %RopeMarker.position
	pin.node_a = harpoon.get_path()
	pin.node_b = fish_body.get_path()
	pin.softness = 1.0

	dangling_fish.append(fish_body)
	dangling_fish.append(pin)
	
func _on_tier_changed(new_tier: int, _old_tier: int) -> void:
	tier = new_tier

## Called by harpoon when it finishes retracting — cleans up leftover tween appearances.
func clear_tweened_fish() -> void:
	for fish_vis in impaled_fish:
		if is_instance_valid(fish_vis):
			fish_vis.queue_free()
	impaled_fish.clear()
	
func damage_fish_appearance(appearance: Node2D) -> Node2D:
	# Check if this fish has custom damaged scenes (e.g. shark)
	if appearance.has_meta("damaged_scenes"):
		var scenes: Array = appearance.get_meta("damaged_scenes")
		# Pick scene based on tier: index 0 = low tier, index 1 = high tier (tier >= 2)
		var scene_index: int = 1 if tier >= 2 else 0
		scene_index = clampi(scene_index, 0, scenes.size() - 1)
		var damaged_appearance = scenes[scene_index].instantiate()
		damaged_appearance.scale = appearance.scale
		return damaged_appearance
	
	# Default: use fish head for basic fish
	var damaged_appearance = fish_head.instantiate()
	damaged_appearance.scale = appearance.scale
	return damaged_appearance
