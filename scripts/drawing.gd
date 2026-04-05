extends Node
class_name Drawing

var img: Image :
	set(image):
		img = image
		_parse_image()

var cropped_img: Image

var resized_img: Image
var resolution_analyse := 32.0

var width: float
var height: float

var pixels_drawns: Array[Vector2]
var boundary = {
	"minX": -1, 
	"maxX": -1, 
	"minY": -1, 
	"maxY": -1,
}

var dist_map: Array

func set_drawing(texture: ViewportTexture):
	var image = texture.get_image()

	if image == null:
		printerr("Erreur : Impossible de récupérer l'image du Viewport")
		return
		
	self.img = image


func set_target(image: Image):
	self.img = image

func _parse_image():
	self.width = self.img.get_width()
	self.height = self.img.get_height()
	
	for x in range(self.width):
		for y in range(self.height):
				
			if self.img.get_pixel(x, y) != Color.WHITE:
				#print(Vector2(x, y))
				self._set_bounds(x, y)
				
				pixels_drawns.append(Vector2(x, y))

func dilate() -> Drawing:
	var width = img.get_width()
	var height = img.get_height()

	var result = Image.create(width, height, false, Image.FORMAT_L8)

	var directions = [
		Vector2i(0,0),
		Vector2i(1,0), Vector2i(-1,0),
		Vector2i(0,1), Vector2i(0,-1)
	]

	for x in range(width):
		for y in range(height):
			var is_black = false

			for dir in directions:
				var nx = x + dir.x
				var ny = y + dir.y

				if nx >= 0 and ny >= 0 and nx < width and ny < height:
					if img.get_pixel(nx, ny).r < 0.5:
						is_black = true
						break

			if is_black:
				result.set_pixel(x, y, Color.BLACK)
			else:
				result.set_pixel(x, y, Color.WHITE)

	self.img = result
	return self

func set_cropped_image():
	if boundary.minX == -1:
		printerr("Aucun dessin détecté")
		return
	
	print(boundary)
	
	var crop_width = boundary.maxX - boundary.minX + 1
	var crop_height = boundary.maxY - boundary.minY + 1
	
	var rect = Rect2i(
		boundary.minX,
		boundary.minY,
		crop_width,
		crop_height
	)
	
	self.cropped_img = img.get_region(rect)

func resize_img():
	cropped_img.resize(resolution_analyse, resolution_analyse, Image.INTERPOLATE_BILINEAR)

func _set_bounds(x: int, y: int):
	if x < boundary.minX or boundary.minX == -1: boundary.minX = x
	if x > boundary.maxX or boundary.maxX == -1: boundary.maxX = x
	if y < boundary.minY or boundary.minY == -1: boundary.minY = y
	if y > boundary.maxY or boundary.maxY == -1: boundary.maxY = y


func compute_distance_map() -> Array:
	var width = cropped_img.get_width()
	var height = cropped_img.get_height()
	
	# Create map at maximum
	var dist = []
	for x in range(width):
		dist.append([])
		for y in range(height):
			dist[x].append(9999)

	var queue = []
	
	# Init : pixels noirs = distance 0
	for x in range(self.resolution_analyse):
		for y in range(self.resolution_analyse):
			if cropped_img.get_pixel(x, y).r < 0.5:
				dist[x][y] = 0
				queue.append(Vector2i(x, y))

	var directions = [
		Vector2i(1,0), Vector2i(-1,0),
		Vector2i(0,1), Vector2i(0,-1)
	]

	# BFS
	while queue.size() > 0:
		var current = queue.pop_front()
		var cx = current.x
		var cy = current.y

		for dir in directions:
			var nx = cx + dir.x
			var ny = cy + dir.y

			if nx >= 0 and ny >= 0 and nx < width and ny < height:
				if dist[nx][ny] > dist[cx][cy] + 1:
					dist[nx][ny] = dist[cx][cy] + 1
					queue.append(Vector2i(nx, ny))
	self.dist_map = dist
	
	for x in dist:
		var line = ""
		for y in x:
			line +=  ". " if y <= 0 else str(y) + " "
		print(line)
	
	return dist


	
