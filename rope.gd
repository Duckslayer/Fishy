extends Line2D

@export_group("Targets")
@export var boat_marker_path : NodePath
@export var harpoon_marker_path : NodePath

@export_group("Physics")
@export var rope_points : int = 500
@export var rope_drag : float = 1.0 # Lower = loose/wavy, Higher = tight
@export_range(1.0, 10.0) var density_falloff : float = 4.0

@onready var boat_marker = get_node(boat_marker_path)
@onready var harpoon_marker = get_node(harpoon_marker_path)

@export var debug_points : bool = true

func _ready():
	# Initialize the line with the correct number of segments
	clear_points()
	add_point(boat_marker.global_position)
	for i in range(1, rope_points):
		add_point(harpoon_marker.global_position)

func _process(delta):
	if !boat_marker or !harpoon_marker:
		return

	var start_pos = boat_marker.global_position #to_local(boat_marker.global_position)
	var end_pos = harpoon_marker.global_position #to_local(harpoon_marker.global_position)

	# Set first and last
	set_point_position(0, start_pos)
	set_point_position(points.size() - 1, end_pos)
	
	for i in range(1, points.size() - 1): # Do not include the first or last point
		# Find where this point "should" be on a perfectly straight line
		var ratio = float(i) / float(points.size() - 1)
		var curved_ratio = 1.0 - pow(1.0 - ratio, density_falloff)
		
		var ideal_pos = start_pos.lerp(end_pos, ratio)
		
		# Get where the point currently is
		var current_pos = get_point_position(i)
		
		# Gently move the current point toward the ideal point
		# The 'rope_drag' controls how fast it catches up
		var new_pos = current_pos.lerp(ideal_pos, rope_drag * delta)
		
		set_point_position(i, new_pos)
		
	queue_redraw()
	
func _draw():
	if !debug_points:
		return

	for i in range(get_point_count()):
		var pos = get_point_position(i)
	
		# Draw a small red circle at the point's location
		# Syntax: draw_circle(position, radius, color)
		draw_circle(pos, 5.0, Color.RED)
		
		# Optional: Draw the index number to see the ordering
		# draw_string(ThemeDB.fallback_font, pos + Vector2(5, -5), str(i))
