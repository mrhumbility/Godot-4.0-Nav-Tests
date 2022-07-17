extends Node3D

@onready var selection_box_3d = preload("res://ui/selection_box_3d.tscn")

const RAY_LENGTH = 1000

var units = []

var _mdrag_start = Vector2()
var _mdrag_end = Vector2()
var _is_dragging = false

var paths: Array = []

func _ready():
	GameManager.startup($Units, $Cam, $NavigationRegion3D/map_002)
	GameManager.spawnUnits()
	GameManager.move_units.connect(_move_units.bind())
	GameManager.append_destination.connect(_append_destination.bind())
	
	if(Input.get_mouse_mode() != 3):
		Input.set_mouse_mode(3)


func _move_units(click_pos):
	if GameManager.selected_entities.size() == 0:
		return
	GameManager.selected_entities.shuffle()
	units = GameManager.selected_entities.get_selection()
	var positions = _mouse_to_global_pos(click_pos)
	for i in units.size():
		units[i].set_destination(positions[i][0], positions[i][1], i, units.size())


func _append_destination(click_pos):
	if GameManager.selected_entities.size() == 0:
		return
	units = GameManager.selected_entities.get_selection()
	if !GameManager.selected_entities.is_shuffled():
		GameManager.selected_entities.shuffle()
		units = GameManager.selected_entities.get_selection()
	var positions = _mouse_to_global_pos(click_pos)
	for i in units.size():
		units[i].append_destination(positions[i][0], positions[i][1], i, units.size())


func _mouse_to_global_pos(click_pos):
	$RayCast3D.global_transform.origin = $Cam.global_transform.origin
	$RayCast3D.target_position = $Cam.project_ray_normal(click_pos) * RAY_LENGTH
	$RayCast3D.force_raycast_update()
	var ground_pos = $RayCast3D.get_collision_point()
	var goal_positions = Utils.calc_goal_position(ground_pos, units.size())
	var positions = []
	for i in range(units.size()):
		var goal_pos = goal_positions[i]
		# Recast the ray to make sure the goal pos is on the surface of the ground
		# Does adjust the goal pos a little bit but not much
		$RayCast3D.global_transform.origin = $Cam.project_ray_origin(click_pos)
		$RayCast3D.target_position = (goal_pos - $RayCast3D.global_transform.origin).normalized() * RAY_LENGTH
		$RayCast3D.force_raycast_update()
		goal_pos = $RayCast3D.get_collision_point()
		positions.append([goal_pos, ground_pos])
	return positions


# Mouse Input stuff for selecting
func _input(event):
	# Might need to use event more instead of Input in here. Not 100% sure if 
	# this is safe or might have some unsafe moments
	if event is InputEventMouseButton:
		var shifting = Input.is_action_pressed('shift')
		if Input.is_action_just_pressed('left_click'):
			_mdrag_start = event.global_position
			_mdrag_end = event.global_position
			_is_dragging = true
			GameManager.emit_signal('dragging', _is_dragging, shifting, _mdrag_start, false)
		if Input.is_action_just_released('left_click'):
			_mdrag_end = event.global_position
			_is_dragging = false
			if _mdrag_start.distance_to(_mdrag_end) > 5: # just a little buffer so we dont collide with clicks
				GameManager.emit_signal('dragging', _is_dragging, shifting, _mdrag_end, true)
			else:
				GameManager.emit_signal('dragging', _is_dragging, shifting, _mdrag_end, false)
		
		if Input.is_action_just_released('right_click'):
			if Input.is_action_pressed('shift'):
				GameManager.emit_signal('append_destination', event.global_position)
			else:
				GameManager.emit_signal('move_units', event.global_position)


#func _process(delta):
#	if GameManager.selected_entities.size() > 0:
#		# There are only units right now so just assuming that unit.destinations will not fail\
#		for unit in GameManager.selected_entities.get_selection():
#			if unit.destinations.size() > 0 and !paths.has(unit.destinations['click_pos']):
#				paths.append(unit.destinations['click_pos'])
#				var dot = MeshInstance3D.new()
#				dot.mesh = BoxMesh.new()
#				dot.position = unit.destinations['click_pos']

