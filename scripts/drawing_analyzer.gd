class_name DrawingAnalyzer extends Node

@onready var sub_viewport: SubViewport = $"../SubViewport"
@onready var debug_display: CanvasLayer = $"../DebugDisplay"
@onready var drawing_controller: RayCastController = $".."

@export var resolution_analyse := 32
@export var texture_modele: Texture2D
var pixels_modele = []
var centre_modele = Vector2.ZERO

@onready var base: TextureRect = $"../DebugDisplay/Base"
@onready var cropped: TextureRect = $"../DebugDisplay/Cropped"

signal new_score(score: int)

func _ready() -> void:
	_prepare_modele()


func _prepare_modele():
	if not texture_modele:
		print("Erreur : Aucune texture modèle assignée dans l'inspecteur !")
		return
		
	return texture_modele.get_image()




func analyze():
	# attend que le cpu ait finit de dessiner la frame
	await RenderingServer.frame_post_draw
	
	var target_drawing = Drawing.new()
	target_drawing.set_target(drawing_controller.image_modele)
	#target_drawing.dilate()
	target_drawing.set_cropped_image()
	target_drawing.resize_img()
	target_drawing.compute_distance_map()
	
	var player_drawing = Drawing.new()
	player_drawing.set_drawing(sub_viewport.get_texture())
	#player_drawing.dilate()
	player_drawing.set_cropped_image()
	player_drawing.resize_img()
	player_drawing.compute_distance_map()
	
	base.texture = ImageTexture.create_from_image(target_drawing.cropped_img)
	cropped.texture = ImageTexture.create_from_image(player_drawing.cropped_img)

	
	var compare = DrawingCompare.create(target_drawing, player_drawing).compute_iou()
	compare.compute_distance_score(target_drawing.dist_map, player_drawing.cropped_img)
	var score = compare.compute_final_score()
	new_score.emit(score)
	
