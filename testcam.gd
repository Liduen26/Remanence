extends Camera3D
@onready var lamp_switch = $"../Audio/Lamp_switch"
@onready var pcdie = $"../Audio/pcdie"



func _do_traveling():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:z", 0.85, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -55.0, 1.5)
	
	await get_tree().create_timer(1.0).timeout
	lamp_switch.play()
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = true
	
	
	
	


func _reverse_traveling():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:z", 0.7, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -17.5, 1.5)
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = false


	
