extends CharacterBody2D

@export var dive_speed = 400.0
@export var retract_speed = 600.0

enum State { IDLE, DIVING, RETRACTING }
var current_state = State.IDLE

@onready var trail_particles = $TrailBubblesParticles

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_input()
		State.DIVING:
			handle_diving(delta)
		State.RETRACTING:
			handle_retracting(delta)
			
	#%Background.get_node("WaterCanvas/WaterRect").material.set_shader_parameter("harpoon_y", global_position.y)

func handle_idle_input():
	if Input.is_action_just_pressed("ui_accept"):
		current_state = State.DIVING
		trail_particles.emitting = true

func handle_diving(delta):
	velocity.y = dive_speed
	move_and_slide()
	
	# Condition 1: Max depth safety check (example)
	if global_position.y > 20000:
		return_to_boat()

func handle_retracting(delta):
	var target_y = 0 
	global_position.y = move_toward(global_position.y, target_y, retract_speed * delta)
	
	# Once we reach the top, reset
	if global_position.y <= target_y:
		current_state = State.IDLE
		trail_particles.emitting = false

func return_to_boat():
	if current_state == State.DIVING:
		current_state = State.RETRACTING
		# You can add "Juice" here later: sound effects, camera shake, etc.
