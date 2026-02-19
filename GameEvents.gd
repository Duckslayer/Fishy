extends Node

signal fish_kill(value : int)
signal intensity_changed(value : float)
signal fish_impaled(appearance : Node2D)

var combo: int = 0
var max_combo: int = 10
var intensity: float = 0.0

func _ready() -> void:
	fish_kill.connect(_on_fish_killed)

func _on_fish_killed(_value: int) -> void:
	combo += 1
	intensity = clampf(float(combo) / float(max_combo), 0.0, 1.0)
	intensity_changed.emit(intensity)
	hitstop()

func reset_combo() -> void:
	combo = 0
	intensity = 0.0
	intensity_changed.emit(intensity)

func hitstop() -> void:
	var base_duration: float = 0.05
	var max_duration: float = 0.12
	var duration: float = lerpf(base_duration, max_duration, intensity)
	
	Engine.time_scale = 0.05
	# process_always = true so the timer ticks even while time_scale is near zero
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
