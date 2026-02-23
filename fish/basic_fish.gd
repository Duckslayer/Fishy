extends BaseFish

func _ready() -> void:
	$Appearance.scale *= size_scale

func _process(delta: float) -> void:
	var direction := Vector2.from_angle(global_rotation)
	position += direction * speed * delta

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	die()
