extends Control


const RECT_CLR = Color(0.35, 0.6, 0.78, 0.3)  # blue color
const LINE_CLR = Color(0, 0, 0, 0.75)  # black color
const LINE_WIDTH = 1  # line width in pixels

var mdrag_start = Vector2()
var mdrag_end = Vector2()
var _dragging = false

func _ready():
	GameManager.dragging.connect(_set_dragging.bind())

func _process(delta):
	if _dragging:
		mdrag_end = get_global_mouse_position()
		update()

func _set_dragging(dragging, shifting, bbox_val, false_alarm):
	_dragging = dragging
	if(_dragging):
		mdrag_start = bbox_val
		mdrag_end = bbox_val
		update()
	else:
		mdrag_end = get_global_mouse_position()
		update()

func _draw():
	if _dragging:  #draw outline around drag_rect
		var size = Vector2(abs(mdrag_start.x - mdrag_end.x), abs(mdrag_start.y - mdrag_end.y))
		var pos = Vector2(min(mdrag_start.x, mdrag_end.x), min(mdrag_start.y, mdrag_end.y))
		draw_rect(Rect2(pos, size), RECT_CLR)
		draw_line(mdrag_start, Vector2(mdrag_end.x, mdrag_start.y), LINE_CLR, LINE_WIDTH)  # top line
		draw_line(Vector2(mdrag_end.x, mdrag_start.y), mdrag_end, LINE_CLR, LINE_WIDTH)  # right line
		draw_line(Vector2(mdrag_start.x, mdrag_end.y), mdrag_end, LINE_CLR, LINE_WIDTH)  # bottom line
		draw_line(mdrag_start, Vector2(mdrag_start.x, mdrag_end.y), LINE_CLR, LINE_WIDTH)  # left line
	
