extends Line2D

@export var boat_marker_path : NodePath
@export var harpoon_marker_path : NodePath

@onready var boat_marker = get_node(boat_marker_path)
@onready var harpoon_marker = get_node(harpoon_marker_path)

func _ready():
	# Ensure the line starts with exactly two points
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)

func _process(_delta):
	if boat_marker and harpoon_marker:
		# We use to_local because Line2D points are relative to the Line2D's own position
		set_point_position(0, to_local(boat_marker.global_position))
		set_point_position(1, to_local(harpoon_marker.global_position))
