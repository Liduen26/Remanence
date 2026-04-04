extends Camera3D

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		_start_sequence()

func _start_sequence():
		#affiche img
	get_node("../Objects/Monitor/Monitor/img").visible = true
	
	#attend
	await get_tree().create_timer(3.0).timeout
	
	#etein ecran
	get_node("../Objects/Monitor/Monitor/MeshInstance3D").visible = false
	get_node("../Objects/Monitor/Monitor/img").visible = false
	
	await get_tree().create_timer(1.0).timeout
	_do_traveling()

func _do_traveling():
	var tween = create_tween()
	tween.set_parallel(true)  
	tween.tween_property(self, "position:z", 0.85, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -55.0, 1.5)
	
	await get_tree().create_timer(1.0).timeout
	# allumer la lampe fin du travel
	await tween.finished
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = true
