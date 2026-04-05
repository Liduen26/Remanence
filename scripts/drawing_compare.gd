extends Node
class_name DrawingCompare

var target_image: Drawing
var drawing: Drawing

var score_iou: float
var score_distance: float

const CHEATING_MULT = 2

static func create(target_image: Drawing, drawing: Drawing) -> DrawingCompare:
	var drawingCompare = DrawingCompare.new()
	
	drawingCompare.target_image = target_image
	drawingCompare.drawing = drawing
	
	return drawingCompare


func compute_iou() -> DrawingCompare:
	var intersection = 0
	var union = 0

	for x in range(self.target_image.cropped_img.get_width()):
		for y in range(self.target_image.cropped_img.get_height()):
			var p1 = self.target_image.cropped_img.get_pixel(x, y).r < 0.5
			var p2 = self.drawing.cropped_img.get_pixel(x, y).r < 0.5

			if p1 or p2:
				union += 1
			if p1 and p2:
				intersection += 1

	if union == 0:
		self.score_iou = 1.0
	
	self.score_iou = float(intersection) / float(union)
	
	print("-------------------------")
	print("intersec : ", str(float(intersection)), "; union : ", str(float(union)))
	print("SCORE IoU : ", score_iou)
	print("-------------------------")
	
	return self

func compute_distance_score(distance_map: Array, drawing: Image) -> float:
	var total = 0.0
	var count = 0

	for x in range(drawing.get_width()):
		for y in range(drawing.get_height()):
			var is_black = drawing.get_pixel(x, y).r < 0.5
			if is_black:
				total += distance_map[x][y]
				count += 1

	if count == 0:
		return 0.0

	var avg = total / count
	
	self.score_distance = 1.0 / (1.0 + avg)
	
	print("-------------------------")
	print("total : ", str(total), "; count : ", str(count), "; average : ", str(avg))
	print("SCORE DISTANCE : ", score_distance)
	print("-------------------------")
	
	return self.score_distance

func compute_final_score() -> float:
	var iou = self.score_iou
	var dist_score = self.score_distance

	var final_score = (0.5 * iou + 0.5 * dist_score) * CHEATING_MULT
	final_score = final_score * 100
	final_score = clamp(final_score, 0, 100)
	
	print("-------------------------")
	print("FINAL SCORE : ", final_score, " / 100")
	print("-------------------------")

	return final_score
