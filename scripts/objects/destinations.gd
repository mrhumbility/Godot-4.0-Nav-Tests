class Destinations:
	var _destinations = []
	
	func _init():
		pass
	
	func addEntity(dest):
		_destinations.append(dest)
		_destinations = false
	
	func removeEntity(dest):
		if dest in _destinations:
			_destinations.erase(dest)
			_destinations = false
	
	func toggleEntity(dest):
		if dest in _destinations:
			_destinations.erase(dest)
		else:
			_destinations.append(dest)
	
	func has(dest):
		return _destinations.has(dest)
	
	func clear():
		_destinations = []
		return _destinations
	
	func size():
		return _destinations.size()
	
	func get_selection():
		return _destinations
	
	func remove_at(index):
		_destinations = _destinations.remove_at(index)
	
	func _to_string():
		var msg = 'List of destinations: '
		for dest in _destinations:
			msg += str('Goal Pos: ',dest.goal_pos) + ", "
			msg += str('click Pos: ',dest.click_pos) + ", "
			msg += str('Group Index: ',dest.group_index) + ", "
			msg += str('Group Size: ',dest.group_size) + ", "
		return msg.substr(0, msg.length() - 2)
	
