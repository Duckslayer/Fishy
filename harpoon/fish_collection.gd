extends Node

## Manages impaled fish appearances and dangling physics fish on the harpoon.

var dangling_fish_scene: PackedScene = preload("res://fish/dangling_fish.tscn")

# Track the tween appearances (temporary) and the dangling bodies (persistent)
var impaled_fish: Array[Node2D] = []
var dangling_fish: Array[Node] = []  # RigidBody2D + PinJoint2D instances

@onready var harpoon: CharacterBody2D = get_parent()

func _ready() -> void:
	GameEvents.fish_impaled.connect(_on_fish_impaled)

func _on_fish_impaled(appearance: Node2D) -> void:
	# Adopt the fish's visual as a child of the harpoon
	harpoon.add_child(appearance)
	# Random offset near the harpoon tip so multiple fish don't perfectly overlap
	appearance.position = %CollisionPolygon2D.position + Vector2(randf_range(-8, 8), randf_range(-5, 15))
	appearance.rotation = randf_range(-0.3, 0.3)
	impaled_fish.append(appearance)

	var fish_length: float = appearance.get_node("Body").texture.get_width() * appearance.scale.x
	var direction: Vector2 = (%RopeMarker.position - appearance.position).normalized()

	# Slide to rope marker and fade out
	var tween := harpoon.create_tween()
	tween.set_parallel(true)
	tween.tween_property(appearance, "position", %RopeMarker.position + (direction * fish_length * 0.4), 0.2)
	tween.tween_property(appearance, "rotation", PI / 2, 0.2)

	tween.finished.connect(func() -> void:
		if is_instance_valid(appearance):
			_spawn_dangling_fish(appearance)
			appearance.queue_free()
			impaled_fish.erase(appearance)
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

## Called by harpoon when it finishes retracting — cleans up leftover tween appearances.
func clear_tweened_fish() -> void:
	for fish_vis in impaled_fish:
		if is_instance_valid(fish_vis):
			fish_vis.queue_free()
	impaled_fish.clear()
