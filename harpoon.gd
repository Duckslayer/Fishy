extends CharacterBody2D

@export var dive_speed = 400.0
@export var retract_speed = 6000.0
@export var steering_speed = 3.0
@export var max_turn_rad = deg_to_rad(25.0)

enum State { IDLE, DIVING, RETRACTING }
var current_state = State.IDLE

@onready var trail_particles = $TrailBubblesParticles
@onready var start_position = global_position

var rope_status = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#if not rope_status:
		#spawn_rope()
		
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

func handle_diving(delta):
	turn(delta)
	
	velocity = Vector2.DOWN.rotated(rotation) * dive_speed
	
	move_and_slide()
	
	if global_position.y > 20000:
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
		
func turn(delta):
	var turn_dir = Input.get_axis("Right", "Left")
	
	if turn_dir:
		rotation += turn_dir * steering_speed * delta
	rotation = clamp(rotation, -max_turn_rad, max_turn_rad)
	
func spawn_rope():
	const ROPE = preload("uid://5o1lw3jndjyf")
	var trailing_rope = ROPE.instantiate()
	add_child(trailing_rope)
	
	trailing_rope.create_rope(get_node("."))
	rope_status = true

func return_to_boat():
	if current_state == State.DIVING:
		current_state = State.RETRACTING
		# You can add "Juice" here later: sound effects, camera shake, etc.
