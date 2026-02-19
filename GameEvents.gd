extends Node

signal fish_kill(value : int)
signal intensity_changed(value : float)

var combo: int = 0
var max_combo: int = 10
var intensity: float = 0.0

func _ready() -> void:
	fish_kill.connect(_on_fish_killed)

func _on_fish_killed(_value: int) -> void:
	combo += 1
	intensity = clampf(float(combo) / float(max_combo), 0.0, 1.0)
	intensity_changed.emit(intensity)

func reset_combo() -> void:
	combo = 0
	intensity = 0.0
	intensity_changed.emit(intensity)
