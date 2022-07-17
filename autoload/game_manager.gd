extends Node3D

signal selection_updated
signal area_selected
signal move_units
signal append_destination
signal dragging

var selected_entities = preload("res://scripts/objects/selection.gd").Selection.new()
var units : Node3D
var camera : Camera3D
var map : Node3D

func startup(_units, _camera, _map):
	units = _units
	camera = _camera
	map = _map


func spawnUnits():
	for node in map.get_children():
		if 'Spawner' in node.name:
			node.start()


func set_selection(entities):
	selected_entities.clear()
	for entity in entities:
		selected_entities.addEntity(entity)
	print(selected_entities)
	emit_signal('selection_updated')


func append_selection(entities):
	for entity in entities:
		selected_entities.addEntity(entity)
	print(selected_entities)
	emit_signal('selection_updated')


func toggle_selection(entities):
	for entity in entities:
		selected_entities.toggleEntity(entity)
	print(selected_entities)
	emit_signal('selection_updated')
