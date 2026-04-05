extends Node
class_name GameManager

@onready var drawing_controller: RayCastController = $"../DrawingController"
@onready var pcdie: AudioStreamPlayer3D = $"../Audio/pcdie"
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var level_timer: Timer = $LevelTimer

@export var game_time_sec := 60

var time_left := 0

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
	if Input.is_action_just_pressed("Analyse"):
		_stop_sequence()



func _start_sequence():
	# Choisir une image random
	var images = ["champidead", "chat", "diamond", "duck"]
	var chosen = images[randi() % images.size()]
	var image = Image.new()
	image.load("res://assets/Images/" + chosen + ".png")
	print(image)
	
	var img = get_node("../Objects/Monitor/Monitor/img")
	img.get_surface_override_material(0).albedo_texture = ImageTexture.create_from_image(image)
	drawing_controller.image_modele = image
	
	# Affiche img
	var viewport = get_node("../Objects/Monitor/Monitor/MeshInstance3D/SubViewport")
	viewport.get_node("TitleLabel").visible = false
	viewport.get_node("StartLabel").visible = false
	viewport.get_node("ScoreLabel").visible = false
	img.visible = true
	
	# Attend
	await get_tree().create_timer(3.0).timeout
	
	# Eteint écran
	pcdie.play()
	get_node("../Objects/Monitor/Monitor/MeshInstance3D").visible = false
	img.visible = false
	
	#init dessin
	drawing_controller.init()
	
	# init timer
	self.time_left = game_time_sec
	
	await get_tree().create_timer(1.0).timeout
	level_timer.start()
	camera_3d._do_traveling()

func _stop_sequence():
	level_timer.stop()
	camera_3d._reverse_traveling()
	# Affiche img
	get_node("../Objects/Monitor/Monitor/MeshInstance3D").visible = true
	var viewport = get_node("../Objects/Monitor/Monitor/MeshInstance3D/SubViewport")
	viewport.get_node("TitleLabel").visible = true
	viewport.get_node("StartLabel").visible = true
	viewport.get_node("ScoreLabel").visible = true


func _on_level_timer_timeout() -> void:
	if time_left > 0:
		var minutes = time_left / 60
		var seconds = time_left % 60
		# timer
		var label = get_node("../Objects/Digital clock/Digital_clock_Cube/MeshInstance3D/SubViewport/RichTextLabel")
		#print(get_node("../Objects/Digital clock"))
		label.text = "%02d:%02d" % [minutes, seconds]
		time_left -= 1
		
	elif time_left <= 0:
		_stop_sequence()


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
