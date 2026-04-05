extends Node
class_name GameManager

@onready var drawing_controller: RayCastController = $"../DrawingController"
@onready var pcdie: AudioStreamPlayer3D = $"../Audio/pcdie"
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var level_timer: Timer = $LevelTimer

signal high_score_updated(score: int)
var high_score: int = 3:
	set(new_score):
		high_score = new_score
		high_score_updated.emit(new_score)
		save_high_score(new_score)

func _ready() -> void:
	self.high_score = load_high_score()

func _input(event):
	if Input.is_action_just_pressed("Start"):
		_start_sequence()

func _start_sequence():
	#affiche img
	get_node("../Objects/Monitor/Monitor/img").visible = true
	
	#attend
	await get_tree().create_timer(3.0).timeout
	
	#eteint ecran
	pcdie.play()
	get_node("../Objects/Monitor/Monitor/MeshInstance3D").visible = false
	get_node("../Objects/Monitor/Monitor/img").visible = false
	
	await get_tree().create_timer(1.0).timeout
	
	level_timer.start()
	camera_3d._do_traveling()


# Fin de la partie
func _on_level_timer_timeout() -> void:
	
	pass




func _on_drawing_controller_score_updated(score: int) -> void:
	print("score received ", score)
	
	if score > high_score:
		high_score = score
	pass # Replace with function body.






func save_high_score(score: int):
	var data = { "high_score": score }
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_high_score() -> int:
	if not FileAccess.file_exists("user://save.json"):
		return 0
	
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	return data["high_score"]
