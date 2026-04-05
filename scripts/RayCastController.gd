class_name RayCastController extends Node3D

@export var camera: Camera3D
@export var brush_size := 10

@onready var object_to_draw_on: MeshInstance3D = $Paper/MeshInstance3D
@onready var viewport: SubViewport = $SubViewport
@onready var drawing_canvas: Node2D = %DrawingCanvas
@onready var drawing_analyzer: DrawingAnalyzer = %DrawingAnalyzer

var image_modele: Image

const RAY_LENGTH := 10

signal score_updated(score: int)

func _ready() -> void:
	drawing_canvas.brush_size = brush_size
	init()

func init():
	drawing_canvas.initialisation()

func analyze_drawing():
	drawing_analyzer.analyze()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				self._try_draw()
			else:
				drawing_canvas.stop_draw()

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			self._try_draw()

func _try_draw():
	var collid: Dictionary = _shoot_ray()
	if collid and collid.collider is StaticBody3D:
		var pix_pos: Vector2 = _get_face_pos(collid)
		
		_draw(pix_pos)

func _draw(pos: Vector2):
	drawing_canvas.draw_brush(pos)




func _shoot_ray() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_back_faces = true
	query.hit_from_inside = true
	return space_state.intersect_ray(query)
	
func _get_face_pos(collider) -> Vector2:
	var hit_position = collider.position
	var local_pos = collider.collider.to_local(hit_position)

	var plane_size_x = object_to_draw_on.mesh.get_aabb().size.x
	var plane_size_y = object_to_draw_on.mesh.get_aabb().size.y

	var uv_x = (local_pos.x / 2.0) + 0.5
	uv_x = clamp(uv_x, 0.0, 1.0)
	var uv_y = (local_pos.z / 2.0) + 0.5
	uv_y = clamp(uv_y, 0.0, 1.0)

	var uv = Vector2(uv_x, uv_y)

	var viewport_resolution := Vector2(viewport.size)
	var pixel_pos: Vector2 = uv * viewport_resolution

	#pixel_pos.y = viewport_resolution.y - pixel_pos.y
	#print("Coord : ", pixel_pos)
	#print("----------------------------")
	
	return pixel_pos
	


func _on_drawing_analyzer_new_score(score: int) -> void:
	score_updated.emit(score)
