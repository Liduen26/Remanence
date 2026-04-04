extends Node2D

var brush_position = Vector2.ZERO
var draw_requested = false

func draw_brush(pixel_pos: Vector2):
	brush_position = pixel_pos
	draw_requested = true
	
	queue_redraw() 

func _draw():
	if draw_requested:
		draw_circle(brush_position, 10.0, Color.RED)
		draw_requested = false
