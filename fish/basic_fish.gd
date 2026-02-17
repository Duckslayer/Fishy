extends BaseFish

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
	
	# Stop the swim animation
	$AnimationPlayer.stop()
	
	# Create a "Death" tween
	var tween = create_tween().set_parallel(true)
	
	# Try targeting the Sprite directly for the fade
	# and use the full Vector2 for scale
	tween.tween_property($Appearance, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_property($Appearance, "scale", Vector2.ZERO, 0.3)
	
	tween.finished.connect(func(): 
		queue_free()
	)
	
