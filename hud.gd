extends CanvasLayer

func update_score(new_score: int) -> void:
	$Score.text = str(new_score)
