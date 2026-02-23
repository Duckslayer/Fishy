extends CharacterBody2D

@export var dive_speed: float = 400.0
@export var retract_speed: float = 6000.0
@export var steering_speed: float = 4.0
@export var max_turn_rad: float = deg_to_rad(25.0)
@export var max_depth: float = 10000.0

enum State { IDLE, DIVING, RETRACTING }
var current_state: State = State.IDLE

@onready var trail_particles: GPUParticles2D = $TrailBubblesParticles
@onready var rope_controller: Node2D = $RopeMarker/RopeController
@onready var start_position: Vector2 = global_position
@onready var large_bubbles: GPUParticles2D = $LargeBubbles
@onready var fish_collection: Node = $FishCollection
const LARGE_BUBBLES_OFFSET_Y: float = 437.0

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_input(delta)
		State.DIVING:
			handle_diving(delta)
		State.RETRACTING:
			handle_retracting(delta)

	# Keep LargeBubbles upright and directly below the harpoon
	large_bubbles.global_rotation = 0.0
	large_bubbles.global_position = global_position + Vector2(0, LARGE_BUBBLES_OFFSET_Y)

func handle_idle_input(delta: float) -> void:
	turn(delta)
	move_and_slide()

	if Input.is_action_just_pressed("Launch"):
		current_state = State.DIVING
		trail_particles.emitting = true
		start_position = global_position
		rope_controller.set_rope_state(rope_controller.RopeState.SIMULATING)
		IntensityManager.reset_combo()

func handle_diving(delta: float) -> void:
	turn(delta)
	velocity = Vector2.DOWN.rotated(rotation) * dive_speed
	move_and_slide()

	if global_position.y > max_depth:
		return_to_boat()

func handle_retracting(delta: float) -> void:
	global_position = global_position.move_toward(start_position, retract_speed * delta)
	rotation = move_toward(rotation, 0.0, steering_speed * delta)

	if global_position.distance_to(start_position) < 1.0:
		current_state = State.IDLE
		trail_particles.emitting = false
		rotation = 0
		global_position = start_position
		rope_controller.set_rope_state(rope_controller.RopeState.HIDDEN)
		fish_collection.clear_tweened_fish()

func turn(delta: float) -> void:
	var turn_dir := Input.get_axis("Right", "Left")
	if turn_dir:
		rotation += turn_dir * steering_speed * delta
	rotation = clamp(rotation, -max_turn_rad, max_turn_rad)

func return_to_boat() -> void:
	if current_state == State.DIVING:
		current_state = State.RETRACTING
		velocity = Vector2.ZERO
		rope_controller.set_rope_state(rope_controller.RopeState.TAUT)
