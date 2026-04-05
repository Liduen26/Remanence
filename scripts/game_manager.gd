extends Node
class_name GameManager

@onready var drawing_controller: RayCastController = $"../DrawingController"
@onready var pcdie: AudioStreamPlayer3D = $"../Audio/pcdie"
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var level_timer: Timer = $LevelTimer
@onready var theo_1 = $"../Audio/theo1"
@onready var theo_2 = $"../Audio/theo2"
@onready var theo_3 = $"../Audio/theo3"
@onready var theo_4 = $"../Audio/theo4"

@export var game_time_sec := 60

var look_dir := Vector2.ZERO
var time_left := 0
var mouse_captured := false
var game_active := false

var look_rotation: Vector2
var look_speed = 5.0

var img 

signal high_score_updated(score: int)
var high_score: int = 3:
	set(new_score):
		high_score = new_score
		high_score_updated.emit(new_score)
		save_high_score(new_score)

signal last_score(score: int)

func _ready() -> void:
	self.high_score = load_high_score()
	self.game_active = false
	self.img = get_node("../Objects/Monitor/Monitor/img")
	_capture_mouse()


func _input(event):
	if not game_active:
		if Input.is_action_just_pressed("Start"):
			_start_sequence()
			_release_mouse()
			self.game_active = true
		if mouse_captured and event is InputEventMouseMotion:
			look_dir = event.relative

	if Input.is_action_just_pressed("Analyse") and game_active:
		_stop_sequence()
		self.game_active = false
		

func _physics_process(delta: float) -> void:
	if mouse_captured:
		print(look_dir)
		const SPEED_DEMULTIPLIER = 1000
		look_rotation.x -= (look_dir.y * look_speed) / SPEED_DEMULTIPLIER
		look_rotation.x = clamp(look_rotation.x, deg_to_rad(-60), deg_to_rad(-20)) # limit up/down
		camera_3d.rotation.x = look_rotation.x
	
	look_dir = Vector2.ZERO

func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


func _start_sequence():
	# Choisir une image random
	var images = ["champidead", "chat", "diamond", "duck"]
	var chosen = images[randi() % images.size()]
	var image = Image.new()
	image.load("res://assets/Images/" + chosen + ".png")
	print(image)
	
	img.get_surface_override_material(0).albedo_texture = ImageTexture.create_from_image(image)
	drawing_controller.image_modele = image
	
	# Affiche img
	var viewport = get_node("../Objects/Monitor/Monitor/MeshInstance3D/SubViewport")
	viewport.get_node("TitleLabel").visible = false
	viewport.get_node("StartLabel").visible = false
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
	
	# theo
	var dialogues = [theo_1, theo_2, theo_3, theo_4]
	var chosen_dialogue = dialogues[randi() % dialogues.size()]
	chosen_dialogue.play()
	
	await get_tree().create_timer(1.0).timeout
	level_timer.start()
	camera_3d._do_traveling()

func _stop_sequence():
	drawing_controller.analyze_drawing()
	level_timer.stop()
	camera_3d._reverse_traveling()
	# Affiche img
	get_node("../Objects/Monitor/Monitor/MeshInstance3D").visible = true
	var viewport = get_node("../Objects/Monitor/Monitor/MeshInstance3D/SubViewport")
	img.visible = true
	_capture_mouse()


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
	last_score.emit(score)
	
	if score > high_score:
		high_score = score



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
