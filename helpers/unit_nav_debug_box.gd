extends MeshInstance3D

var parent
var mat

const DEBUG_DEFAULT_CLR = Color(1.0, 0.4, 0.9, 0.2)
const DEBUG_FLASH_CLR = Color(1, 0.0, 0.0, 1.0)

func _ready():
	if !Utils.debug:
		queue_free()
	parent = get_parent().get_parent() # debug nodes go inside a node3d
	parent.ready.connect(_parentReady)


func _parentReady():
	# Set debug box scale
	var navRefScale = parent.get_node('NavigationAgent3D').target_desired_distance
	scale = Vector3(navRefScale, navRefScale, navRefScale)
	# Make debug box material unique so we can adjust colors
	mat = get_active_material(0).duplicate()
	set_surface_override_material(0, mat)
	parent.debug_event.connect(_debugFlash)


func _debugFlash():
	_setDebugClr(DEBUG_FLASH_CLR)
	$Timer.stop()
	$Timer.start()


func _setDebugClr(color):
	var mat = get_active_material(0)
	mat.albedo_color = color
	set_surface_override_material(0, mat)


func _on_timer_timeout():
	_setDebugClr(DEBUG_DEFAULT_CLR)
