class Selection:
	var _selection = []
	var _shuffled = false
	
	func _init():
		pass
	
	func addEntity(entity):
		_selection.append(entity)
		_shuffled = false
	
	func removeEntity(entity):
		if entity in _selection:
			_selection.erase(entity)
			_shuffled = false
	
	func toggleEntity(entity):
		if entity in _selection:
			_selection.erase(entity)
			_shuffled = false
		else:
			_selection.append(entity)
			_shuffled = false
	
	func has(entity):
		return _selection.has(entity)
	
	func clear():
		_selection = []
		_shuffled = false
	
	func size():
		return _selection.size()
	
	func shuffle():
		#_selection = Utils.shuffleList(_selection)
		randomize()
		_selection.shuffle()
		_shuffled = true
	
	func get_selection():
		return _selection
	
	func is_shuffled():
		return _shuffled
	
	func _to_string():
		var msg = 'Selection of entities: '
		for entity in _selection:
			msg += str(entity.name) + ", "
		return msg.substr(0, msg.length() - 2)
	
