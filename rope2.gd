extends Node2D

@export var segments = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func create_rope(attachement_body : PhysicsBody2D):
	const ROPE_PIECE = preload("uid://dytj2hxxilpfn")
	var previous_segment = attachement_body
	var attachment_point = previous_segment.get_node("RopeMarker").global_position
	var test = previous_segment.global_position
	
	for i in range(segments):
		var current_rope_piece = ROPE_PIECE.instantiate() as Object
		var pin = current_rope_piece.get_node("PinJoint") as PinJoint2D
		var test2 = pin.position
		add_child(current_rope_piece)
		current_rope_piece.global_position = attachment_point - pin.position
		pin.node_a = previous_segment.get_path()
		pin.node_b = current_rope_piece.get_path()
		
		previous_segment = current_rope_piece
		attachment_point = current_rope_piece.global_position
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
