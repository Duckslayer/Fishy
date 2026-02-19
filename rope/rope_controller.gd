extends Node2D

# SETTINGS
@export var length: float = 300.0
@export var segment_count: int = 100
@export var gravity: Vector2 = Vector2(0, -980)
@export var damp: float = 0.95 # Air resistance (0.9 - 0.99)
@export var constraint_iterations: int = 50 # Higher = stiffer rope
@export var mu : float = 0.01 # "Min spacing"

# NODES
@export var target_node: Node2D # The node the rope hangs from (e.g. Player)
@export var boat_anchor: Marker2D # The boat marker to draw taut rope towards
@onready var line_2d = $Line2D

# STATE
enum RopeState { HIDDEN, SIMULATING, TAUT }
var rope_state: RopeState = RopeState.HIDDEN

# DATA
var pos: PackedVector2Array = []
var prev_pos: PackedVector2Array = []
var segment_length: float

func _ready():
	# Initialize points at the starting position
	segment_length = length / segment_count
	var start_pos = global_position
	
	for i in range(segment_count):
		pos.append(start_pos)
		prev_pos.append(start_pos)
	
	# Start hidden
	set_rope_state(RopeState.HIDDEN)

func set_rope_state(new_state: RopeState) -> void:
	rope_state = new_state
	match rope_state:
		RopeState.HIDDEN:
			line_2d.visible = false
			_reset_points_to_anchor()
		RopeState.SIMULATING:
			line_2d.visible = true
			_reset_points_to_anchor()
			_spool_out()
		RopeState.TAUT:
			line_2d.visible = true

func _reset_points_to_anchor() -> void:
	var anchor = global_position
	if target_node:
		anchor = target_node.global_position
	for i in range(segment_count):
		pos[i] = anchor
		prev_pos[i] = anchor
		
func _spool_out() -> void:
	var start_pos = global_position
	for i in range(segment_count):
		pos[i] = (start_pos + Vector2(-2*mu + randf()*mu, -i * mu)) # Make some "wiggle" so the rope doesn't get stuck in weird math space
		prev_pos[i] = pos[i]

func _physics_process(delta: float) -> void:
	match rope_state:
		RopeState.HIDDEN:
			return
		RopeState.SIMULATING:
			update_points(delta)
			apply_constraints()
			update_visuals()
		RopeState.TAUT:
			update_taut()

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

# 3. TAUT MODE — straight line from harpoon to boat
func update_taut() -> void:
	if not target_node or not boat_anchor:
		return
	
	var start = target_node.global_position
	var end = boat_anchor.global_position
	
	for i in range(segment_count):
		var t = float(i) / float(segment_count - 1)
		pos[i] = start.lerp(end, t)
		prev_pos[i] = pos[i]
	
	update_visuals()
				
# 4. DRAW
func update_visuals():
	# Line2D works in local space, but our math is global.
	# We convert points to local space for drawing.
	var local_points = []
	for p in pos:
		local_points.append(to_local(p))

	line_2d.points = PackedVector2Array(local_points)
