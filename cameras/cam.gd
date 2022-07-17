extends Camera3D

# Getting screen size inside the _process() and _input() functions instead of
# inside _ready() so if the user changes the screensize things dont get messed
# up. Should keep track of this in the settings menu and send out a signal when
# screen size changes instead. Would need some sort of callback if the user is
# in windowed mode and adjusts the screensize manually though. 
# Doing it this way for now. 

const MMB_DRAG_SPEED = 10
const DRAG_SPEED = 20
const ZOOM_SPEED = 1
const MAX_ZOOM_LEVEL = 8
const ZOOM_IN_MULT = 3
const BORDER = 10.0 # % proximity to screen edge

var dragging = false
var mouse_dir = Vector2.ZERO
var zoom_amount = 0


func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		var screen_size = get_viewport().get_visible_rect().size
		if Input.is_action_just_pressed('mmb'):
			Input.set_mouse_mode(2)
		if Input.is_action_just_released('mmb'):
			Input.set_mouse_mode(3)
		if event.is_action('scroll_up') and zoom_amount < MAX_ZOOM_LEVEL * ZOOM_IN_MULT:
			var t = global_transform.origin + project_ray_normal(screen_size * 0.5) * ZOOM_SPEED
			global_transform.origin = t
			zoom_amount += 1
		if event.is_action('scroll_down') and zoom_amount > -MAX_ZOOM_LEVEL:
			var t = global_transform.origin + -project_ray_normal(screen_size * 0.5) * ZOOM_SPEED
			global_transform.origin = t
			zoom_amount -= 1
	if event is InputEventMouseMotion:
		if Input.is_action_pressed('mmb'):
			dragging = true
			var zoom_mult = Utils.fit(zoom_amount,
					-MAX_ZOOM_LEVEL,
					MAX_ZOOM_LEVEL * ZOOM_IN_MULT,
					MMB_DRAG_SPEED * 2,
					MMB_DRAG_SPEED * 0.75)
			mouse_dir = event.relative * zoom_mult


func _process(delta):
	if !dragging and Input.mouse_mode == 3:
		var screen_size = get_viewport().get_visible_rect().size
		var mouse_pos = get_viewport().get_mouse_position()
		var x = Utils.fit(mouse_pos.x, 0, screen_size[0] * (1 / BORDER), -1, 0)
		x += Utils.fit(mouse_pos.x, screen_size[0] - (screen_size[0] * (1 / BORDER)), screen_size[0], 0, 1)
		var y = Utils.fit(mouse_pos.y, 0, screen_size[1] * (1 / BORDER), -1, 0)
		y += Utils.fit(mouse_pos.y, screen_size[1] - (screen_size[1] * (1 / BORDER)), screen_size[1], 0, 1)
		var dir = Vector2(x, y)
		if dir.length() > 0:
			dragging = true
			var zoom_mult = Utils.fit(zoom_amount,
					-MAX_ZOOM_LEVEL,
					MAX_ZOOM_LEVEL * ZOOM_IN_MULT,
					DRAG_SPEED * 2,
					DRAG_SPEED * 0.75)
			mouse_dir = dir * zoom_mult
	
	if dragging:
		mouse_dir *= delta
		var offset = Vector3(mouse_dir[0], 0, mouse_dir[1])
		offset = offset.rotated(Vector3(0, 1, 0), rotation[1])
		position += offset
		dragging = false
		mouse_dir = Vector2.ZERO
