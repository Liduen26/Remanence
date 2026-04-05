extends Node3D

var display_score: int = 0
@onready var high_score_label: RichTextLabel = $Monitor/MeshInstance3D/SubViewport/Scores/HighScoreLabel
@onready var score_label: RichTextLabel = $Monitor/MeshInstance3D/SubViewport/Scores/ScoreLabel


func _on_game_manager_high_score_updated(score: int) -> void:
	high_score_label.text = "Meilleur score : " + str(score) + "%"


func _on_game_manager_last_score(score: int) -> void:
	score_label.text = "Dernier score : " + str(score) + "%"
	
