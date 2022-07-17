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
	
