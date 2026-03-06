extends RigidBody2D

## A physics-based dangling fish that gets pinned to the harpoon.
## Gravity-neutral, responds to harpoon movement via PinJoint2D.

func setup(appearance: Node2D) -> void:
	var appearance_node = Node2D.new()
	appearance_node.name = "Appearance"
	appearance_node.scale = appearance.scale
	add_child(appearance_node)
	
	for child in appearance.get_children():
		if child is Sprite2D:
			var sprite_copy = child.duplicate()
			appearance_node.add_child(sprite_copy)

func _ready() -> void:
	# No gameplay collisions — physics body only for joint simulation
	collision_layer = 0
	collision_mask = 0
	gravity_scale = 0.0
	linear_damp = 2.0
	angular_damp = 2.0
