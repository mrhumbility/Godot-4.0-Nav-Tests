extends Node3D

@onready var selection_box_3d = preload("res://ui/selection_box_3d.tscn")

const RAY_LENGTH = 1000

var units = []

var _mdrag_start = Vector2()
var _mdrag_end = Vector2()
var _is_dragging = false

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
	
	if Input.is_action_just_pressed('esc'):
		if Input.mouse_mode == 3:
			Input.set_mouse_mode(0)
		else:
			Input.set_mouse_mode(3)


func _process(delta):
	var destinations = []
	if GameManager.selected_entities.size() > 0:
		# There are only units right now so just assuming that unit.destinations will not fail
		for unit in GameManager.selected_entities.get_selection():
			if unit.moving:
				if !destinations.has(unit.dest.click_pos):
					destinations.insert(0, unit.dest.click_pos)
				if unit.destinations.size() > 0:
					for dest in unit.destinations.get_destinations():
						if !destinations.has(dest.click_pos):
							destinations.append(dest.click_pos)
# 	# This section is gross
#	for node in $SelectedDestinationDots.get_children():
#		var found = false
#		for dest in new_paths:
#			if node.position == dest.click_pos:
#				found = true
#		if !found:
#			node.queue_free()
#	for dest in new_paths:
#		var found = false
#		for node in $SelectedDestinationDots.get_children():
#			if dest.click_pos == node.position:
#				found = true
#		if !found:
#			var dot = _click_pos_dot(dest.click_pos)
#			$SelectedDestinationDots.add_child(dot)
	
	# This seems a lot simpler. Is this fine? Rebuilding every frame
	# instead of only when needed but with extra for loops and stuff
	for node in $SelectedDestinationDots.get_children():
		node.queue_free()
	
	for i in range(destinations.size()):
		var dest = destinations[i]
		var dot = _click_pos_dot(dest)
		$SelectedDestinationDots.add_child(dot)
		if i + 1 < destinations.size():
			var next_dest = destinations[i + 1]
			var line = _click_pos_line(dest, next_dest)
			$SelectedDestinationDots.add_child(line)


func _click_pos_dot(pos: Vector3):
	# Repalce this with a scene of some sort later
	var dot = MeshInstance3D.new()
	dot.mesh = SphereMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0, 1, 1)
	mat.transparency = 1
	dot.set_surface_override_material(0, mat)
	var r = 0.1
	dot.mesh.radius = r
	dot.mesh.height = r * 1
	dot.position = pos
	return dot

func _click_pos_line(start: Vector3, end: Vector3):
	# Repalce this with a scene of some sort later
	var node = Node3D.new()
	var line = MeshInstance3D.new()
	line.mesh = BoxMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0, 0.5)
	mat.transparency = 1
	line.set_surface_override_material(0, mat)
	var s = 0.025
	line.mesh.size = Vector3(s, s, 1)
	line.position.z += -0.5
	node.add_child(line)
	node.scale.z = start.distance_to(end)
	node.look_at_from_position(start, end)
	return node
