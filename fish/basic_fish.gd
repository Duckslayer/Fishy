extends BaseFish

func _process(delta: float) -> void:
	var direction = Vector2.from_angle(global_rotation)
	var velocity = direction * speed
	position += velocity * delta
