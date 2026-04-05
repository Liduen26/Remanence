extends Camera3D
@onready var lamp_switch = $"../Audio/Lamp_switch"
@onready var pcdie = $"../Audio/pcdie"
@onready var theo_1 = $"../Audio/theo1"
@onready var theo_2 = $"../Audio/theo2"
@onready var theo_3 = $"../Audio/theo3"
@onready var theo_4 = $"../Audio/theo4"

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		_start_sequence()

func _start_sequence():
	# Choisir une image random
	var images = ["champidead", "chat", "diamond", "duck"]
	var chosen = images[randi() % images.size()]
	var texture = load("res://assets/Images/" + chosen + ".png")
	
	var img = get_node("../Objects/Monitor/Monitor/img")
	img.get_surface_override_material(0).albedo_texture = texture
	
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
	
	await get_tree().create_timer(1.0).timeout
	_do_traveling()



func _do_traveling():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:z", 0.85, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -55.0, 1.5)
	
	await get_tree().create_timer(1.0).timeout
	lamp_switch.play()
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = true
	
	# theo
	var dialogues = [theo_1, theo_2, theo_3, theo_4]
	var chosen_dialogue = dialogues[randi() % dialogues.size()]
	chosen_dialogue.play()
	
	# timer
	var label = get_node("../Objects/Digital clock/Digital_clock_Cube/MeshInstance3D/SubViewport/RichTextLabel")
	print(get_node("../Objects/Digital clock"))
	
	_start_timer(label)
	
func _start_timer(label):
	var time_left = 90
	while time_left >= 0:
		var minutes = time_left / 60
		var seconds = time_left % 60
		label.text = "%02d:%02d" % [minutes, seconds]
		await get_tree().create_timer(1.0).timeout
		time_left -= 1
	print("test")
	_reverse_traveling()
	
func _reverse_traveling():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:z", 0.7, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -17.5, 1.5)
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = false
