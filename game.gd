extends Node2D


var score = 0

func _ready() -> void:
	GameEvents.fish_kill.connect(_on_fish_kill)

func _on_fish_kill(value: int) -> void:
	score += value
	%HUD.update_score(score)
