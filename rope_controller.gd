extends Node2D

# SETTINGS
@export var length: float = 300.0
@export var segment_count: int = 20
@export var gravity: Vector2 = Vector2(0, -980)
@export var damp: float = 0.95 # Air resistance (0.9 - 0.99)
@export var constraint_iterations: int = 50 # Higher = stiffer rope

# NODES
@export var target_node: Node2D # The node the rope hangs from (e.g. Player)
@onready var line_2d = $Line2D

# DATA
var pos: PackedVector2Array = []
var prev_pos: PackedVector2Array = []
var segment_length: float

func _ready():
	# Initialize points at the starting position
	segment_length = length / segment_count
	var start_pos = global_position
	
	for i in range(segment_count):
		pos.append(start_pos + Vector2(0, i * segment_length))
		prev_pos.append(start_pos + Vector2(0, i * segment_length))

func _physics_process(delta: float) -> void:
	update_points(delta)
	apply_constraints()
	update_visuals()
	
func update_points(delta: float) -> void:
	for i in range(segment_count):
		# Velocity is implied by (current_pos - prev_pos)
		var velocity = pos[i] - prev_pos[i]

		# Save current position before modifying it
		prev_pos[i] = pos[i]

		# Apply velocity with damping + gravity
		pos[i] += velocity * damp + (gravity * delta * delta)
		
# 2. ENFORCE DISTANCE (The "Stick" Constraint)
func apply_constraints():
	# We loop multiple times to make the rope feel "stiff" and not rubbery
	for _iter in range(constraint_iterations):

		# Constrain the first point to the target (The Player/Hook)
		if target_node:
			pos[0] = target_node.global_position
		else:
			pos[0] = global_position # Or stick to self if no target

		# Constrain the rest of the segments
		for i in range(segment_count - 1):
			var p1 = pos[i]
			var p2 = pos[i+1]

			var diff = p2 - p1
			var dist = diff.length()
			
			# If the points are too far apart or too close, push/pull them
			if dist > 0: # Avoid division by zero
				var error = dist - segment_length
				var direction = diff.normalized()
				
				# Move both points halfway to correct the error
				# (Unless it's the first point, which is locked to the player)
				var correction = direction * error * 0.5

				if i != 0:
					pos[i] += correction
				pos[i+1] -= correction
				
# 3. DRAW
func update_visuals():
	# Line2D works in local space, but our math is global.
	# We convert points to local space for drawing.
	var local_points = []
	for p in pos:
		local_points.append(to_local(p))

	line_2d.points = PackedVector2Array(local_points)
