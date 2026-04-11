extends Node2D

@export var battery_scene: PackedScene

@onready var battery_spawn_points = $BatterySpawnPoints
@onready var battery_container = $BatteryContainer

func _ready():
	randomize()
	spawn_battery()

func spawn_battery():
	print("spawn_battery called")

	# Delete any leftover batteries just in case
	for child in battery_container.get_children():
		child.queue_free()

	var spawn_points = battery_spawn_points.get_children()

	if spawn_points.is_empty():
		print("No battery spawn points found")
		return

	if battery_scene == null:
		print("Battery scene is not assigned")
		return

	var chosen_spawn = spawn_points[randi() % spawn_points.size()]
	var battery = battery_scene.instantiate()

	battery_container.add_child(battery)
	battery.global_position = chosen_spawn.global_position

	print("Spawned battery at: ", battery.global_position)
