extends BaseFish

var points = 10
var blood_burst_scene = preload("res://effects/blood_burst.tscn")

func _ready() -> void:
	$Appearance.scale *= size_scale

func _process(delta: float) -> void:
	var direction = Vector2.from_angle(global_rotation)
	var velocity = direction * speed
	position += velocity * delta

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	die()

func die():
	# Disable collisions immediately so it can't be hit twice
	collision_layer = 0
	collision_mask = 0
	
	# Spawn blood burst at our position
	var blood = blood_burst_scene.instantiate()
	blood.global_position = global_position
	get_parent().add_child(blood)
	
	# Stop the swim animation
	$AnimationPlayer.stop()
	
	# Create a "Death" tween
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property($Appearance, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_property($Appearance, "scale", Vector2.ZERO, 0.3)
	
	tween.finished.connect(func(): 
		queue_free()
	)
	GameEvents.fish_kill.emit(points)
	
