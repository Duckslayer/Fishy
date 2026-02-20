extends CharacterBody2D

@export var dive_speed = 400.0
@export var retract_speed = 6000.0
@export var steering_speed = 3.0
@export var max_turn_rad = deg_to_rad(25.0)
@export var max_kept_fish: int = 50

enum State { IDLE, DIVING, RETRACTING }
var current_state = State.IDLE

var dangling_fish_scene = preload("res://fish/dangling_fish.tscn")

@onready var trail_particles: GPUParticles2D = $TrailBubblesParticles
@onready var trail_material: ParticleProcessMaterial = trail_particles.process_material
@onready var rope_controller = $RopeMarker/RopeController
@onready var start_position = global_position

# Baseline bubble trail values
var base_ratio: float = 0.25  # 15/60 — baseline fraction of max particles
var base_scale_max: float = 0.2
var max_scale_max: float = 0.5
var base_velocity_max: float = 41.0
var max_velocity_max: float = 120.0

# Track the tween appearances (temporary) and the dangling bodies (persistent)
var impaled_fish: Array[Node2D] = []
var dangling_fish: Array[Node] = []  # RigidBody2D instances + PinJoint2D instances

func _ready() -> void:
	# Pre-allocate max particles so we never reallocate mid-emit
	trail_particles.amount = 60
	trail_particles.amount_ratio = base_ratio
	GameEvents.intensity_changed.connect(_on_intensity_changed)
	GameEvents.fish_impaled.connect(_on_fish_impaled)

func _on_fish_impaled(appearance: Node2D) -> void:
	# Adopt the fish's visual as a child of the harpoon
	add_child(appearance)
	# Random offset near the harpoon tip so multiple fish don't perfectly overlap
	appearance.position = %CollisionPolygon2D.position + Vector2(randf_range(-8, 8), randf_range(-5, 15))
	appearance.rotation = randf_range(-0.3, 0.3)
	impaled_fish.append(appearance)
	
	var fish_length = appearance.get_node("Body").texture.get_width() * appearance.scale.x
	var direction = (%RopeMarker.position - appearance.position).normalized()
	
	# Slide to rope marker and fade out (existing tween)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(appearance, "position", %RopeMarker.position + (direction * fish_length * 0.5), 0.2)
	tween.tween_property(appearance, "rotation", PI / 2, 0.2)
	tween.set_parallel(false)
	
	tween.tween_property(appearance, "modulate", Color(1, 1, 1, 0), 0.6)
	tween.finished.connect(func():
		if is_instance_valid(appearance):
			# Spawn the dangling physics fish before freeing the tween appearance
			_spawn_dangling_fish(appearance)
			appearance.queue_free()
			impaled_fish.erase(appearance)
	)

func _spawn_dangling_fish(appearance: Node2D) -> void:
	var fish_body: RigidBody2D = dangling_fish_scene.instantiate()
	fish_body.setup(appearance)
	
	# Add as child of the harpoon so it moves with us
	add_child(fish_body)
	fish_body.position = %RopeMarker.position
	fish_body.rotation = appearance.rotation
	
	# Create a PinJoint2D to attach at the rope marker
	var pin = PinJoint2D.new()
	add_child(pin)
	pin.position = %RopeMarker.position
	pin.node_a = get_path()
	pin.node_b = fish_body.get_path()
	pin.softness = 1.0
	
	dangling_fish.append(fish_body)
	dangling_fish.append(pin)

func _on_intensity_changed(value: float) -> void:
	# amount_ratio (0.0–1.0) controls density without restarting the particle system
	trail_particles.amount_ratio = lerp(base_ratio, 1.0, value)
	trail_material.scale_max = lerp(base_scale_max, max_scale_max, value)
	trail_material.initial_velocity_max = lerp(base_velocity_max, max_velocity_max, value)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_input(delta)
		State.DIVING:
			handle_diving(delta)
		State.RETRACTING:
			handle_retracting(delta)
			
func handle_idle_input(delta):
	turn(delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("Launch"):
		current_state = State.DIVING
		trail_particles.emitting = true
		start_position = global_position
		rope_controller.set_rope_state(rope_controller.RopeState.SIMULATING)
		GameEvents.reset_combo()

func handle_diving(delta):
	turn(delta)
	
	velocity = Vector2.DOWN.rotated(rotation) * dive_speed
	
	move_and_slide()
	
	if global_position.y > 10000:
		return_to_boat()

func handle_retracting(delta):
	global_position = global_position.move_toward(start_position, retract_speed * delta)
	rotation = move_toward(rotation, 0.0, steering_speed * delta)
	# Once we reach the top, reset
	if global_position.distance_to(start_position) < 1.0:
		current_state = State.IDLE
		trail_particles.emitting = false
		rotation = 0 # Ensure perfectly straight
		global_position = start_position
		rope_controller.set_rope_state(rope_controller.RopeState.HIDDEN)
		# Clean up any remaining tween appearances (shouldn't normally be any)
		for fish_vis in impaled_fish:
			if is_instance_valid(fish_vis):
				fish_vis.queue_free()
		impaled_fish.clear()
		# Dangling fish persist — they stay attached and come back up with the harpoon
		
func turn(delta):
	var turn_dir = Input.get_axis("Right", "Left")
	
	if turn_dir:
		rotation += turn_dir * steering_speed * delta
	rotation = clamp(rotation, -max_turn_rad, max_turn_rad)
	

func return_to_boat():
	if current_state == State.DIVING:
		current_state = State.RETRACTING
		velocity = Vector2(0,0)
		rope_controller.set_rope_state(rope_controller.RopeState.TAUT)
		# You can add "Juice" here later: sound effects, camera shake, etc.
