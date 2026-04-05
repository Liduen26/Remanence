extends Node3D

var camera: Camera3D
var drawing_area: MeshInstance3D
var base_position: Vector3
var base_rotation: Vector3
@onready var pencil = $"../Audio/Pencil"

func _ready():
	camera = get_viewport().get_camera_3d()
	drawing_area = get_node("/root/Node3D/DrawingController/Paper/MeshInstance3D")
	base_position = global_position
	base_rotation = rotation_degrees

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, drawing_area.global_position.y)
	var intersection = plane.intersects_ray(origin, direction)
	
	if intersection:
		var local_point = drawing_area.to_local(intersection)
		var aabb = drawing_area.get_aabb()
		
		if aabb.has_point(local_point):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			
			if not pencil.playing:
				pencil.play()
			
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				global_position = Vector3(intersection.x, intersection.y + 0.222, intersection.z + 0.07)
				rotation_degrees.x = lerp(rotation_degrees.x, 90.0, 0.1)
			else:
				global_position = Vector3(intersection.x, intersection.y + 0.222, intersection.z)
				rotation_degrees.x = lerp(rotation_degrees.x, -90.0, 0.1)
			
			rotation_degrees.y = 180.0
			rotation_degrees.z = 0.0
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pencil.stop()
			global_position = base_position
			rotation_degrees.x = lerp(rotation_degrees.x, base_rotation.x, 0.1)
			rotation_degrees.y = base_rotation.y
			rotation_degrees.z = base_rotation.z
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pencil.stop()
		global_position = base_position
		rotation_degrees.x = lerp(rotation_degrees.x, base_rotation.x, 0.1)
		rotation_degrees.y = base_rotation.y
		rotation_degrees.z = base_rotation.z
