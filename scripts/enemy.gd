extends Area2D

enum EnemyType {
	PATROL_HORIZONTAL,
	PATROL_VERTICAL,
	CHARGER,
	COWARD
}

@export var enemy_type: EnemyType = EnemyType.PATROL_HORIZONTAL
@export var move_speed = 80.0
@export var patrol_distance = 50.0
@export var charge_speed = 180.0
@export var flee_speed = 140.0

var start_position = Vector2.ZERO
var direction = 1
var player_in_detection = false
var player_ref = null

func _ready():
	start_position = global_position
	match enemy_type:
		EnemyType.PATROL_HORIZONTAL:
			$Polygon2D.color = Color.RED
		EnemyType.PATROL_VERTICAL:
			$Polygon2D.color = Color.PURPLE
		EnemyType.CHARGER:
			$Polygon2D.color = Color.ORANGE
		EnemyType.COWARD:
			$Polygon2D.color = Color.CYAN

func _physics_process(delta):
	var move_vector = Vector2.ZERO

	match enemy_type:
		EnemyType.PATROL_HORIZONTAL:
			if global_position.x >= start_position.x + patrol_distance:
				direction = -1
			elif global_position.x <= start_position.x - patrol_distance:
				direction = 1

			move_vector = Vector2(direction * move_speed, 0)

		EnemyType.PATROL_VERTICAL:
			if global_position.y >= start_position.y + patrol_distance:
				direction = -1
			elif global_position.y <= start_position.y - patrol_distance:
				direction = 1

			move_vector = Vector2(0, direction * move_speed)

		EnemyType.CHARGER:
			if player_in_detection and is_instance_valid(player_ref):
				var dx = player_ref.global_position.x - global_position.x
				if abs(dx) > 2:
					move_vector = Vector2(sign(dx) * charge_speed, 0)

		EnemyType.COWARD:
			if player_in_detection and is_instance_valid(player_ref):
				var dx = global_position.x - player_ref.global_position.x
				if abs(dx) > 2:
					move_vector = Vector2(sign(dx) * flee_speed, 0)

	global_position += move_vector * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.is_dashing:
			body.reset_dash()
			body.restore_power(body.power_restore_on_kill)
			queue_free()
		else:
			body.die()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_detection = true
		player_ref = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_detection = false
		player_ref = null
