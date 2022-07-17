extends Node3D

@export var continuous_spawn: bool = false
@export var single_spawn_amount: int = 20
@export_range(0, 60) var spawn_interval: float = 1


@onready var penguinUnitPreload = preload("res://units/penguin.tscn")

var loaded = false

# Overiding some of the timer variables so dont set them on the timer itself
func _ready():
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.one_shot = !continuous_spawn


func start():
	if continuous_spawn:
		_spawn_unit()
		$SpawnTimer.start()
	else:
		var positions = Utils.calc_goal_position(global_transform.origin, single_spawn_amount)
		for i in range(single_spawn_amount):
			_spawn_unit(positions[i])


func _on_spawn_timer_timeout():
	# putting here in case user changes this value while the game is running
	$SpawnTimer.one_shot = !continuous_spawn
	if continuous_spawn:
		_spawn_unit()
		return


func _spawn_unit(pos:Vector3 = global_transform.origin):
	var new_unit = penguinUnitPreload.instantiate()
	new_unit.set_position(pos)
	new_unit.set_destination(pos, pos, 0, 1)
	GameManager.units.add_child(new_unit)
