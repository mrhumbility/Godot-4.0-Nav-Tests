extends Node

var rnd = RandomNumberGenerator.new()

var debug = false #

func fit(val, minin, maxin, minout, maxout):
	val = clamp(val, minin, maxin)
	var oldrange = float(maxin) - float(minin)
	var newrange = float(maxout) - float(minout)
	var newval = (((float(val) - minin) * newrange) / oldrange) + minout
	return newval

func calc_goal_position(goal_pos, num_units):
	# Scatter points around an origin
	var click_pos = goal_pos
	var positions = []
	var size = 0.15
	var buffer = 0.05
	size += size * buffer
	var count = 0
	var ring_num = 0
	var num_this_ring = 1
	var radius = 0
	for i in range(num_units):
		goal_pos = click_pos
		var angle = count * (360.0 / num_this_ring)
		angle = deg2rad(angle)
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var pos = Vector2(radius * cos(angle), radius * sin(angle))
		goal_pos.x += pos.x
		goal_pos.z += pos.y
		positions.append(goal_pos)
		count += 1
		if(count == num_this_ring):
			ring_num += 1
			num_this_ring = ring_num * 6
			radius = size * (2 * ring_num)
			count = 0
	return positions

func shuffleList(list):
	var shuffledList = []
	var indexList = range(list.size())
	for i in range(list.size()):
		var x = randi()%indexList.size()
		shuffledList.append(list[indexList[x]])
		indexList.pop_at(x)
	return shuffledList


func randColor():
	rnd.randomize()
	return Color(rnd.randf_range(0.0, 1.0), rnd.randf_range(0.0, 1.0), rnd.randf_range(0.0, 1.0))

func randInt(min, max):
	rnd.randomize()
	return int(rnd.randf_range(min, max))

func isPtInBounds(p: Vector2, bbs: Vector2, bbe: Vector2):
	# point
	# bounding box start
	# bounding box end
	var startx = min(bbs[0], bbe[0])
	var starty = min(bbs[1], bbe[1])
	var endx = max(bbs[0], bbe[0])
	var endy = max(bbs[1], bbe[1])
	if(startx <= p[0] && p[0] <=endx && starty <= p[1] && p[1] <= endy):
		return true
	return false
