class Destination:
	var goal_pos: Vector3
	var click_pos: Vector3
	var group_index: int
	var group_size: int
	
	func _init(_goal_pos, _click_pos, _group_index, _group_size):
		self.goal_pos = _goal_pos
		self.click_pos = _click_pos
		self.group_index = _group_index
		self.group_size = _group_size
	
	func _to_string():
		var msg = 'Destination Object: '
		msg += str('Goal Pos: ',goal_pos) + ", "
		msg += str('click Pos: ',click_pos) + ", "
		msg += str('Group Index: ',group_index) + ", "
		msg += str('Group Size: ',group_size) + ", "
		return msg.substr(0, msg.length() - 2)
