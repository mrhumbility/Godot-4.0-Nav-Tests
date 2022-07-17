extends Area3D

const Z_DIST = 100


var selected_entities = []
var _dragging = false
var _false_alarm = false
var _shifting = false
var _bbox_start = Vector2.ZERO
var _bbox_end = Vector2.ZERO
var _tmpShape = ConvexPolygonShape3D.new()
var _st = SurfaceTool.new()
var _tmpMesh = ArrayMesh.new()

var _mat = StandardMaterial3D.new()
var _color = Color(1, 0, 0, 0.73)


func _ready():
	GameManager.dragging.connect(_set_dragging.bind())
	_mat.transparency = 1
	_mat.albedo_color = _color
	pass

func _checkNewSelection(_bbox_start, _bbox_end):
	var bbox_start = Vector2(min(_bbox_start[0], _bbox_end[0]), min(_bbox_start[1], _bbox_end[1]))
	var bbox_end = Vector2(max(_bbox_start[0], _bbox_end[0]), max(_bbox_start[1], _bbox_end[1]))
	
	var midpoint = (bbox_start + bbox_end) / 2
	var camDir = GameManager.camera.project_ray_normal(midpoint)
	var camPos = GameManager.camera.global_transform.origin
	var dir1 = GameManager.camera.project_ray_normal(bbox_start)
	var dir2 = GameManager.camera.project_ray_normal(Vector2(bbox_end[0], bbox_start[1]))
	var dir3 = GameManager.camera.project_ray_normal(Vector2(bbox_start[0], bbox_end[1]))
	var dir4 = GameManager.camera.project_ray_normal(bbox_end)
	
	var vertices = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Got this working but I'm sure it could be done cleaner/ more readably
	# at the very least
	# front face
	_make_tri(vertices, uvs, camPos, dir1, dir2, dir3)
	_make_tri(vertices, uvs, camPos, dir3, dir2, dir4)
	# back face
	_make_tri(vertices, uvs, camPos, dir3 * Z_DIST, dir2 * Z_DIST, dir1 * Z_DIST)
	_make_tri(vertices, uvs, camPos, dir4 * Z_DIST, dir2 * Z_DIST, dir3 * Z_DIST)
	# left face
	_make_tri(vertices, uvs, camPos, dir1 * Z_DIST, dir1, dir3 * Z_DIST)
	_make_tri(vertices, uvs, camPos, dir1 , dir3, dir3 * Z_DIST)
	# top face
	_make_tri(vertices, uvs, camPos, dir1, dir1 * Z_DIST, dir2 * Z_DIST)
	_make_tri(vertices, uvs, camPos, dir2 * Z_DIST, dir2, dir1)
	# right face
	_make_tri(vertices, uvs, camPos, dir2, dir2 * Z_DIST, dir4 * Z_DIST)
	_make_tri(vertices, uvs, camPos, dir2 , dir4 * Z_DIST, dir4)
	# bottom face
	_make_tri(vertices, uvs, camPos, dir4 * Z_DIST, dir3 * Z_DIST, dir4)
	_make_tri(vertices, uvs, camPos, dir3, dir4, dir3 * Z_DIST)
	
	_tmpShape.points = vertices
	$CollisionShape3D.shape = _tmpShape
	
	# Can set MeshInstance to visable to see the selection box in game (while its active)
	_st.clear()
	_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_st.set_material(_mat)
	for i in vertices.size():
		_st.set_color(_color)
		_st.set_uv(uvs[i])
		_st.add_vertex(vertices[i])
	_tmpMesh = _st.commit()
	$MeshInstance3D.mesh = _tmpMesh
	return


func _process(delta):
	if _dragging:
		selected_entities = []
		_checkNewSelection(_bbox_start, _bbox_end)
		for body in get_overlapping_bodies():
			if &"units" in body.get_groups() and body not in selected_entities:
				selected_entities.append(body)


func _input(event):
	if _dragging and event is InputEventMouse:
		_bbox_end = event.global_position


func _set_dragging(dragging, shifting, bbox_val, false_alarm):
	_dragging = dragging
	_false_alarm = false_alarm
	_shifting = shifting
	if _dragging:
		_bbox_start = bbox_val
		_bbox_end = bbox_val
	else:
		$Timer.start()
		

func _on_timer_timeout():
	# This feels sketchy af but I'm doing this so that if you drag select
	# and release lmb on top of an entity, the signal that entity emits
	# does not collide with this drag selection. Feels extremely race-conditiony
	# though. Having trouble thinking of a different solution that doesnt involve
	# a timer elsewhere though.. unless the solution has something to do with 
	# _unhandeled_input(event) but I'm not really sure how to impliment that
	# since I'm relying on an event callback on the units for click selection.
	if(selected_entities.size() > 0 and _false_alarm):
		if _shifting:
			if(selected_entities.size() == 1):
				GameManager.toggle_selection(selected_entities)
			else:
				GameManager.append_selection(selected_entities)
		else:
			GameManager.set_selection(selected_entities)
	selected_entities = []
	_tmpShape.points = PackedVector3Array()
	$CollisionShape3D.shape = _tmpShape
	_st.clear()
	_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_tmpMesh = _st.commit()
	$MeshInstance3D.mesh = _tmpMesh


func _make_tri(vertices, uvs, origin, offset1, offset2, offset3):
	vertices.push_back(origin + offset1)
	vertices.push_back(origin + offset2)
	vertices.push_back(origin + offset3)
	
	uvs.push_back(Vector2(0, 0))
	uvs.push_back(Vector2(0, 1))
	uvs.push_back(Vector2(1, 1))	
