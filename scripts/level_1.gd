extends Node2D

@export var battery_scene: PackedScene
@export var enemy_scene: PackedScene

@onready var battery_spawn_points = $BatterySpawnPoints
@onready var battery_container = $BatteryContainer
@onready var enemy_spawn_points = $EnemySpawnPoints
@onready var enemy_container = $EnemyContainer
@onready var player = $Player

func _ready():
	randomize()
	spawn_battery()
	spawn_enemies_for_score()

func spawn_battery():
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

func spawn_enemies_for_score():
	if enemy_scene == null:
		print("Enemy scene is not assigned")
		return

	var spawn_points = enemy_spawn_points.get_children()

	if spawn_points.is_empty():
		print("No enemy spawn points found")
		return

	var target_enemy_count = min(2 + int(player.score / 2), 6)
	var current_enemy_count = enemy_container.get_child_count()

	if current_enemy_count >= target_enemy_count:
		return

	var available_spawns = spawn_points.duplicate()
	available_spawns.shuffle()

	var enemies_to_spawn = target_enemy_count - current_enemy_count

	for i in range(min(enemies_to_spawn, available_spawns.size())):
		var chosen_spawn = available_spawns[i]
		var enemy = enemy_scene.instantiate()

		if randi() % 2 == 0:
			enemy.enemy_type = 0  # PATROL_HORIZONTAL
		else:
			enemy.enemy_type = 1  # PATROL_VERTICAL

		enemy_container.add_child(enemy)
		enemy.global_position = chosen_spawn.global_position
