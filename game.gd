extends Node2D


var score = 0
@onready var bubble_occluder: LightOccluder2D = $BubbleOccluder

func _ready() -> void:
	GameEvents.fish_kill.connect(_on_fish_kill)

func _process(_delta: float) -> void:
	_update_bubble_occluder()

func _update_bubble_occluder() -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var cam_pos = camera.global_position
	var viewport_size = get_viewport().get_visible_rect().size
	var visible_size = viewport_size / camera.zoom
	var half_w = visible_size.x / 2.0
	var half_h = visible_size.y / 2.0
	
	# The occluder should cover everything above the water surface (y = 0)
	# within the camera view, with generous margins
	var margin = 200.0
	var left = cam_pos.x - half_w - margin
	var right = cam_pos.x + half_w + margin
	var top = cam_pos.y - half_h - margin
	var bottom = 0.0  # Water surface
	
	bubble_occluder.occluder.polygon = PackedVector2Array([
		Vector2(left, bottom),
		Vector2(right, bottom),
		Vector2(right, top),
		Vector2(left, top)
	])

func _on_fish_kill(value: int) -> void:
	score += value
	%HUD.update_score(score)
