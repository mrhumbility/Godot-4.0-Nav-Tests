extends RigidDynamicBody3D

signal debug_event
signal unit_selected

var goal_pos : Vector3
var click_pos : Vector3
var group_index = 0
var group_size = 1
var destinations = []
var selected = false

const SPEED = 3
const ACC = 4
var vel = Vector3.ZERO
var moving = false


func _ready():
	GameManager.selection_updated.connect(_selection_updated)
	if !Utils.debug:
		$DebugNodes.queue_free()
	else:
		$DebugNodes.visible = true
	
	# Give random color on spawn
	var mat = $MeshInstance3D.get_active_material(0).duplicate()
	mat.albedo_color = Utils.randColor()
	$MeshInstance3D.set_surface_override_material(0, mat)


#func _integrate_forces(_state):
func _physics_process(delta):
	if $NavigationAgent3D.is_target_reachable() and !$NavigationAgent3D.is_navigation_finished():
		moving = true
		if !$NavigationAgent3D.is_navigation_finished():
			var target_pos = $NavigationAgent3D.get_next_location()
			var final_pos = $NavigationAgent3D.get_final_location()
			
			var dir = global_transform.origin.direction_to(target_pos).normalized()
			var mag = vel.length() + (ACC * delta)
			mag = clamp(mag, 0, SPEED)
			vel = dir * mag
			
			$NavigationAgent3D.set_velocity(vel)
			set_linear_velocity(vel)
	elif !$NavigationAgent3D.is_navigation_finished():
		moving = false
		_debugFlash()
		if $IdleTimer.is_stopped():
			$IdleTimer.start()
	else:
		moving = false


func _process(delta):
	var dist = global_transform.origin.distance_to(goal_pos)
	if ($NavigationAgent3D.is_navigation_finished() and
			dist > $NavigationAgent3D.target_desired_distance * 2 and
			$IdleTimer.is_stopped()):
		$IdleTimer.start()
	$ProgressBar.visible = selected
	var screen_pos = GameManager.camera.unproject_position(global_transform.origin + $TopOfHead.position)
	$ProgressBar.position = Vector2(screen_pos[0] - ($ProgressBar.size[0] * 0.5), screen_pos[1] - 5)
	


func set_destination(_goal_pos:Vector3, _click_pos, _group_index, _group_size):
	var destination = {
		'goal_pos': _goal_pos,
		'click_pos': _click_pos,
		'group_index': _group_index,
		'group_size': _group_size,
		}
	destinations.clear()
	destinations.append(destination)
	_next_destination()


func _next_destination():
	goal_pos = destinations[0]['goal_pos']
	click_pos = destinations[0]['click_pos']
	group_index = destinations[0]['group_index']
	group_size = destinations[0]['group_size']
	$NavigationAgent3D.set_target_location(goal_pos)
	destinations.remove_at(0)
	#print('New destination for: ' + str(name) + ' - ' + str(goal_pos))


func _reset_destination():
	var positions = Utils.calc_goal_position(click_pos, group_size)
	goal_pos = positions[group_index]
	group_index = Utils.randInt(0, group_size)
	$NavigationAgent3D.set_target_location(goal_pos)


func append_destination(_goal_pos, _click_pos, _group_index, _group_size):
	var destination = {
		'goal_pos': _goal_pos,
		'click_pos': _click_pos,
		'group_index': _group_index,
		'group_size': _group_size,
		}
	destinations.append(destination)
	if !moving:
		_next_destination()


func _on_navigation_agent_3d_navigation_finished():
	if destinations.size() > 0:
		_next_destination()
	else:
		vel = Vector3.ZERO


func _debugFlash():
	emit_signal('debug_event')


func _on_idle_timer_timeout():
	if !moving:
		_reset_destination()
	#_debugFlash()


func _on_penguin_sleeping_state_changed():
	if sleeping:
		#_debugFlash()
		pass


func _on_penguin_input_event(camera, event, position, normal, shape_idx):
	# Should the drag select ui toggle something on the game manager for a short
	# period after a drag selection to guard against colliding with drag selection here?
	# At the moment I guard against with a timer in the selection_box_3d which feels
	# like a sketchy race condition-y solution
	if event is InputEventMouseButton and event.is_action_released('left_click'):
		if Input.is_action_pressed('shift'):
			GameManager.toggle_selection([self])
		else:
			GameManager.set_selection([self])

func _selection_updated():
	selected = GameManager.selected_entities.has(self)
	print(selected)


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	# not sure if this function is needed or doing anything useful
#	if moving:
#		vel = safe_velocity
#		set_linear_velocity(vel)
	pass 
