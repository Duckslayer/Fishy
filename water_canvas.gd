extends CanvasLayer

# The Ocean ColorRect
@onready var ocean_rect: ColorRect = $Ocean
@onready var ocean_mat: ShaderMaterial = ocean_rect.material

# World Y coordinate where the water surface actually exists
@export var sea_level_y: float = 0.0

func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	# 1. Calculate distance from camera center to sea level
	# If camera.y > sea_level_y, we are underwater (positive diff)
	var dist_below_surface = camera.global_position.y - sea_level_y

	# 2. Get the visible height of the screen in world units
	# We must account for Zoom! If zoomed in (2.0), the visible height is smaller.
	var viewport_height = get_viewport().get_visible_rect().size.y
	var visible_world_height = viewport_height / camera.zoom.y
	
	# 3. Convert that world distance into Screen UV coordinates (0.0 to 1.0)
	# The center of the screen is 0.5.
	# If we are 100px down, the surface moves 100px UP visually.
	var uv_offset = dist_below_surface / visible_world_height
	var target_surface_level = 0.5 - uv_offset

	# 4. Update the shader
	ocean_mat.set_shader_parameter("surface_level", target_surface_level)
