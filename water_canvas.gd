extends CanvasLayer

@onready var ocean_mat: ShaderMaterial = $Ocean.material

@export var sea_level_y: float = 0.0
@export var max_depth_y: float = 50000.0 # The Y-coord where it becomes pitch black

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera: return

	var cam_y = camera.global_position.y
	var viewport_height = get_viewport().get_visible_rect().size.y
	var visible_world_height = viewport_height / camera.zoom.y
	
	# --- 1. Surface Level (Visual Position) ---
	var dist_below_surface = cam_y - sea_level_y
	var target_surface_level = 0.5 - (dist_below_surface / visible_world_height)
	ocean_mat.set_shader_parameter("surface_level", target_surface_level)
	
	# --- 2. Global Depth (Darkness Factor) ---
	# Calculate 0.0 to 1.0 based on how far we are from the surface to max depth
	var depth_percent = clamp(dist_below_surface / max_depth_y, 0.0, 1.0)
	ocean_mat.set_shader_parameter("global_depth", depth_percent)
