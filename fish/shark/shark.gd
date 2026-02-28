extends BaseFish

var damaged_shark_scene: PackedScene = preload("res://fish/shark/damaged_shark.tscn")
var dead_shark_scene: PackedScene = preload("res://fish/shark/dead_shark.tscn")

func _ready() -> void:
	speed = 70.0
	points = 50
	$Appearance.scale *= size_scale * 0.5
	# Set damaged appearance scenes on the Appearance node for fish_collection to use
	$Appearance.set_meta("damaged_scenes", [damaged_shark_scene, dead_shark_scene])

func _process(delta: float) -> void:
	var direction := Vector2.from_angle(global_rotation)
	position += direction * speed * delta

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	die()
