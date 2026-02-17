extends Node2D


var score = 0

func _on_basic_fish_fish_kill(value: int) -> void:
	score += value
	%HUD.update_score(score)
