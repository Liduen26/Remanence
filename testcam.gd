extends Camera3D
@onready var lamp_switch: AudioStreamPlayer3D = $"../Audio/Lamp_switch"


func _do_traveling():
	var tween = create_tween()
	tween.set_parallel(true)  
	tween.tween_property(self, "position:z", 0.85, 1.5)
	tween.tween_property(self, "rotation_degrees:x", -55.0, 1.5)
	
	await get_tree().create_timer(1.0).timeout
	lamp_switch.play()
	get_node("../Objects/lamp_desk2/SpotLight3D").visible = true
