extends Node

## Visual feedback that scales with intensity: bubble trail, harpoon glow, sprite shader.

# Baseline bubble trail values
var base_ratio: float = 0.25
var base_scale_max: float = 0.2
var max_scale_max: float = 0.5
var base_velocity_max: float = 41.0
var max_velocity_max: float = 120.0

# Glow state
var glow_tween: Tween = null
var current_sprite_glow: float = 0.0

# Energy targets per tier: CALM=0, HEATED=1.5, RAMPAGE=2.5, FRENZY=4.0
const TIER_GLOW_ENERGY: Array[float] = [0.0, 1.5, 2.5, 4.0]
# Shader glow_intensity per tier: CALM=0, HEATED=0.4, RAMPAGE=0.7, FRENZY=1.0
const TIER_SPRITE_GLOW: Array[float] = [0.0, 0.4, 0.7, 1.0]

@onready var trail_particles: GPUParticles2D = get_parent().get_node("TrailBubblesParticles")
@onready var trail_material: ParticleProcessMaterial = trail_particles.process_material
@onready var harpoon_glow: PointLight2D = get_parent().get_node("HeadSprite/HarpoonGlow")
@onready var harpoon_sprite_mat: ShaderMaterial = get_parent().get_node("HeadSprite").material

func _ready() -> void:
	# Pre-allocate max particles so we never reallocate mid-emit
	trail_particles.amount = 60
	trail_particles.amount_ratio = base_ratio
	GameEvents.intensity_changed.connect(_on_intensity_changed)
	GameEvents.tier_changed.connect(_on_tier_changed)

func _on_intensity_changed(value: float) -> void:
	trail_particles.amount_ratio = lerp(base_ratio, 1.0, value)
	trail_material.scale_max = lerp(base_scale_max, max_scale_max, value)
	trail_material.initial_velocity_max = lerp(base_velocity_max, max_velocity_max, value)

func _on_tier_changed(new_tier: int, _old_tier: int) -> void:
	var target_energy: float = TIER_GLOW_ENERGY[new_tier]
	var target_sprite_glow: float = TIER_SPRITE_GLOW[new_tier]
	if glow_tween and glow_tween.is_valid():
		glow_tween.kill()
	glow_tween = create_tween().set_parallel(true)
	glow_tween.tween_property(harpoon_glow, "energy", target_energy, 0.3).set_ease(Tween.EASE_OUT)
	glow_tween.tween_method(_set_sprite_glow, current_sprite_glow, target_sprite_glow, 0.3).set_ease(Tween.EASE_OUT)

func _set_sprite_glow(value: float) -> void:
	current_sprite_glow = value
	harpoon_sprite_mat.set_shader_parameter("glow_intensity", value)
