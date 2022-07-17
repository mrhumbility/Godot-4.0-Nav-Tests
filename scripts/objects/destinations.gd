class Destinations:
	var _destinations = []
	
	
	
	
	func _init():
		pass
	
	func append(dest):
		_destinations.append(dest)
	
	func remove(dest):
		if dest in _destinations:
			_destinations.erase(dest)
	
	func has(dest):
		return _destinations.has(dest)
	
	func clear():
		_destinations = []
	
	func size():
		return _destinations.size()
	
	func get_destinations():
		return _destinations
	
	func remove_at(index):
		_destinations.remove_at(index)
	
	func replace(index, val):
		_destinations[index] = val
	
	func first():
		return _destinations[0]
	
	func at(index):
		return _destinations[index]
	
	func _to_string():
		var msg = 'List of destinations:\n'
		for dest in _destinations:
			msg += str('Goal Pos: ',dest.goal_pos) + ", "
			msg += str('click Pos: ',dest.click_pos) + ", "
			msg += str('Group Index: ',dest.group_index) + ", "
			msg += str('Group Size: ',dest.group_size) + "  \n"
		return msg.substr(0, msg.length() - 2)
	
