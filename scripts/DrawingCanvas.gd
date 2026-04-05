extends Node2D

var current_position := Vector2.ZERO
var last_position := Vector2(-1, -1)
var draw_requested = false
var init = true

var brush_size: float

func _ready() -> void:
	initialisation()

func initialisation():
	init = true
	queue_redraw() 

func draw_brush(pos: Vector2):
	if last_position == Vector2(-1, -1):
		last_position = pos
	
	current_position = pos
	draw_requested = true
	
	queue_redraw() 

func stop_draw():
	last_position = Vector2(-1, -1)

func _draw():
	if init:
		draw_rect(Rect2(0, 0, 512, 512), Color.WHITE)
		init = false
	
	elif draw_requested and last_position != Vector2(-1, -1):
		draw_line(last_position, current_position, Color.BLACK, brush_size, true)
		draw_circle(current_position, brush_size / 2, Color.BLACK)
		
		last_position = current_position
		draw_requested = false
	
