extends Node3D

var display_score: int = 0
@onready var score_label: RichTextLabel = $Monitor/MeshInstance3D/SubViewport/ScoreLabel


func _on_game_manager_high_score_updated(score: int) -> void:
	score_label.text = "Meilleur score : " + str(score) + "%"
