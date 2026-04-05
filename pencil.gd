extends Node3D

var camera: Camera3D
var drawing_area: MeshInstance3D
var base_position: Vector3
var base_rotation: Vector3

func _ready():
	camera = get_viewport().get_camera_3d()
	drawing_area = get_node("/root/Node3D/DrawingController/Paper/MeshInstance3D")
	
	# Sauvegarde la position et rotation de base
	base_position = global_position
	base_rotation = rotation_degrees

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, drawing_area.global_position.y)
	var intersection = plane.intersects_ray(origin, direction)
	
	if intersection:
		var aabb = drawing_area.get_aabb()
		var area_pos = drawing_area.global_position
		var half = aabb.size / 2.0
		
		if (intersection.x > area_pos.x - half.x and
			intersection.x < area_pos.x + half.x and
			intersection.z > area_pos.z - half.z and
			intersection.z < area_pos.z + half.z):
			
			# Dans la zone → suit la souris
			global_position = Vector3(intersection.x, intersection.y + 0.5, intersection.z)
			rotation_degrees = Vector3(7.0, 180.0, 0.0)
		else:
			# Hors zone → retour à la position de base
			global_position = base_position
			rotation_degrees = base_rotation
	else:
		# Pas d'intersection → retour à la position de base
		global_position = base_position
		rotation_degrees = base_rotation
