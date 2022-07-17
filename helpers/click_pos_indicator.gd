extends MeshInstance3D

var parent

func _ready():
	parent = get_parent().get_parent()
	parent.ready.connect(_parentReady)
	if !Utils.debug:
		queue_free()


func _process(delta):
	if parent.moving:
		visible = true
		global_transform.origin = parent.dest.click_pos
	else:
		visible = false


func _parentReady():
	for child in parent.get_children():
		if child is MeshInstance3D:
			var mat = get_active_material(0).duplicate()
			mat.albedo_color = child.get_active_material(0).albedo_color
			set_surface_override_material(0, mat)
			return
