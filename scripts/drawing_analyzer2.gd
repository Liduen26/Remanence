class_name DrawingAnalyzer2 extends Node

@onready var sub_viewport: SubViewport = $"../SubViewport"
@onready var debug_display: CanvasLayer = $"../DebugDisplay"

@export var resolution_analyse := 32
@export var texture_modele: Texture2D
var pixels_modele = []
var centre_modele = Vector2.ZERO

func _ready() -> void:
	_prepare_modele()


func _prepare_modele():
	if not texture_modele:
		print("Erreur : Aucune texture modèle assignée dans l'inspecteur !")
		return
		
	return texture_modele.get_image()
	#var image = texture_modele.get_image()
	#image.resize(resolution_analyse, resolution_analyse, Image.INTERPOLATE_BILINEAR)
#
	#for x in range(image.get_width()):
		#for y in range(image.get_height()):
			#var color = image.get_pixel(x, y)
			#if color.a > 0.1: # On garde les pixels non-transparents
				#pixels_modele.append(Vector2(x, y))
				#
	#if pixels_modele.size() > 0:
		#centre_modele = calc_barycentre(pixels_modele)
		#print("Modèle chargé ! Nombre de pixels : ", pixels_modele.size())


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Analyse"):
		_analyze()	


func _analyze():
	# attend que le cpu ait finit de dessiner la frame
	await RenderingServer.frame_post_draw
	
	var drawing := _get_drawing()
	drawing = _pre_processing(drawing)
	
	var modele = _prepare_modele()
	modele = _pre_processing(modele)
	var score = calculate_aligned_iou(modele, drawing)
	
	print("-------------------------")
	print("SCORE FINAL : ", round(score), " / 100")
	print("-------------------------")
	
	#var pixels_drawns: Array[Vector2] = _get_pixels_drawns(image)
	#var center_drawing: Vector2 = calc_barycentre(pixels_drawns)
	#_compare_imgs(pixels_drawns, center_drawing)
	
	

func _get_pixels_drawns(image: Image):
	var pixels_dessines: Array[Vector2] = []
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var color = image.get_pixel(x, y)
			# Comme on a un fond transparent, on cherche les pixels opaques
			if color == Color.BLACK: 
				pixels_dessines.append(Vector2(x, y))

	if pixels_dessines.is_empty():
		return
	
	print("Analyse terminée. Nombre de pixels : ", pixels_dessines.size())
	
	return pixels_dessines

func calc_barycentre(list_pixels: Array) -> Vector2:
	var sum_x = 0.0
	var sum_y = 0.0

	for pixel in list_pixels:
		sum_x += pixel.x
		sum_y += pixel.y
	
	var center_drawing := Vector2(sum_x / list_pixels.size(), sum_y / list_pixels.size())
	print("Centre de masse : ", center_drawing)
	
	return center_drawing

func _get_drawing() -> Image:
	var texture = sub_viewport.get_texture()
	var image = texture.get_image()

	if image == null:
		printerr("Erreur : Impossible de récupérer l'image du Viewport")
		return
		
	return image

func _pre_processing(image: Image) -> Image:
	image.resize(resolution_analyse, resolution_analyse, Image.INTERPOLATE_BILINEAR)
	return image




# Analyse une image et renvoie son centre de masse et le nombre de pixels coloriés
func analyze_drawing(img: Image) -> Dictionary:
	var sum_x = 0
	var sum_y = 0
	var count = 0

	var width = img.get_width()
	var height = img.get_height()

	for x in range(width):
		for y in range(height):
			# On ignore les pixels blancs
			if img.get_pixel(x, y) != Color.WHITE:
				sum_x += x
				sum_y += y
				count += 1
				
	var center = Vector2i.ZERO
	if count > 0:
		# Le centre est la moyenne des positions de tous les pixels coloriés
		center = Vector2i(sum_x / count, sum_y / count)
		
	return {"center": center, "count": count}

func calculate_aligned_iou(target_image: Image, user_image: Image) -> float:
	# 1. On analyse les deux images
	var target_data = analyze_drawing(target_image)
	var user_data = analyze_drawing(user_image)

	# Si le joueur n'a absolument rien dessiné (écran tout blanc)
	if user_data.count == 0:
		return 0.0
	_save_img(target_image, "target")
	_save_img(user_image, "user")
		
	# 2. On calcule le décalage entre le dessin du joueur et le modèle
	var offset = target_data.center - user_data.center
	print(offset)
	var intersection = 0
	var width = target_image.get_width()
	var height = target_image.get_height()
	
	# 3. On calcule l'intersection en appliquant le décalage
	for x in range(width):
		for y in range(height):
			if target_image.get_pixel(x, y) != Color.WHITE:
				
				# On regarde où ce pixel devrait se trouver sur le dessin du joueur
				var user_x = x - offset.x
				var user_y = y - offset.y

				print("user coords : " + str(user_x) + ", " + str(user_y))
				# On vérifie que le pixel décalé ne sort pas de l'image
				if user_x >= 0 and user_x < width and user_y >= 0 and user_y < height:
					# Si le joueur a aussi colorié ce pixel, on a une intersection !
					if user_image.get_pixel(user_x, user_y) != Color.WHITE:
						intersection += 1
	
	# 4. On calcule l'Union grâce à la formule mathématique (beaucoup plus rapide !)
	var union = target_data.count + user_data.count - intersection
	print("union " + str(union))
	if union == 0:
		return 1.0
		
	return float(intersection) / float(union)

func _compare_imgs(pixels_drawn, center_drawing):
	# Alignement (Invariance en translation)
	var offset = centre_modele - center_drawing
	var aligned_pixels = []
	for pixel in pixels_drawn:
		aligned_pixels.append(pixel + offset)
		
	# 2. Calcul de la distance (Erreur moyenne)
	var total_error = 0.0

	# Pour chaque pixel dessiné, on cherche le pixel du modèle le plus proche
	for p_drawing in aligned_pixels:
		var distance_min = 99999.0
		for p_modele in pixels_modele:
			var dist = p_drawing.distance_to(p_modele)
			if dist < distance_min:
				distance_min = dist
		total_error += distance_min
		
	# On fait la moyenne pour ne pas pénaliser un dessin juste parce qu'il a des traits plus épais
	var average_error = total_error / max(1, aligned_pixels.size())

	# 3. Conversion en Score sur 100
	# "tolerance" est le nombre de pixels d'écart moyen pour avoir un score de 0.
	# Si tolerance = 10.0, un écart moyen de 5 pixels donnera 50/100.
	# À toi de l'ajuster (entre 5.0 et 20.0) pour régler la difficulté de ton jeu !
	var tolerance = 10.0 

	var score_raw = 100.0 - ((average_error / tolerance) * 100.0)
	var score_final = clamp(score_raw, 0.0, 100.0) # On empêche d'avoir des scores négatifs

	print("-------------------------")
	print("Erreur moyenne : ", average_error, " pixels")
	print("SCORE FINAL : ", round(score_final), " / 100")
	print("-------------------------")


func _save_img(image: Image, name: String):
	# Génère un chemin unique avec l'heure
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var target_path = "res://assets_" + name + "_" + timestamp + ".png"

	image.save_png(target_path)
