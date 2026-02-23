extends GPUParticles2D

func _ready() -> void:
	# Scale particle count and size based on current intensity
	var i = IntensityManager.intensity
	amount = int(lerp(20.0, 50.0, i))
	
	var mat := process_material as ParticleProcessMaterial
	mat.scale_min = lerp(0.09, 0.18, i)
	mat.scale_max = lerp(0.16, 0.32, i)
	mat.initial_velocity_min = lerp(40.0, 80.0, i)
	mat.initial_velocity_max = lerp(80.0, 160.0, i)
	
	emitting = true
	# Auto-free after particles expire
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
