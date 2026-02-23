extends Node

signal fish_kill(value : int)
signal intensity_changed(value : float)
signal fish_impaled(appearance : Node2D)
signal tier_changed(new_tier : int, old_tier : int)

enum Tier { CALM, HEATED, RAMPAGE, FRENZY }
const TIER_THRESHOLDS: Array[int] = [0, 5, 10, 15]

var combo: int = 0
var max_combo: int = 15
var intensity: float = 0.0
var current_tier: int = Tier.CALM

func _ready() -> void:
	fish_kill.connect(_on_fish_killed)

func _on_fish_killed(_value: int) -> void:
	combo += 1
	intensity = clampf(float(combo) / float(max_combo), 0.0, 1.0)
	intensity_changed.emit(intensity)
	_update_tier()
	hitstop()

func _update_tier() -> void:
	var new_tier: int = Tier.CALM
	for i in range(TIER_THRESHOLDS.size() - 1, -1, -1):
		if combo >= TIER_THRESHOLDS[i]:
			new_tier = i
			break
	if new_tier != current_tier:
		var old_tier: int = current_tier
		current_tier = new_tier
		tier_changed.emit(new_tier, old_tier)

func reset_combo() -> void:
	combo = 0
	intensity = 0.0
	intensity_changed.emit(intensity)
	if current_tier != Tier.CALM:
		var old_tier: int = current_tier
		current_tier = Tier.CALM
		tier_changed.emit(Tier.CALM, old_tier)

func hitstop() -> void:
	var base_duration: float = 0.05
	var max_duration: float = 0.12
	var duration: float = lerpf(base_duration, max_duration, intensity)
	
	Engine.time_scale = 0.05
	# process_always = true so the timer ticks even while time_scale is near zero
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
