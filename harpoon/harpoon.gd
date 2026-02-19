extends CharacterBody2D

@export var dive_speed = 400.0
@export var retract_speed = 6000.0
@export var steering_speed = 3.0
@export var max_turn_rad = deg_to_rad(25.0)

enum State { IDLE, DIVING, RETRACTING }
var current_state = State.IDLE

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

func _ready() -> void:
	# Pre-allocate max particles so we never reallocate mid-emit
	trail_particles.amount = 60
	trail_particles.amount_ratio = base_ratio
	GameEvents.intensity_changed.connect(_on_intensity_changed)

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
