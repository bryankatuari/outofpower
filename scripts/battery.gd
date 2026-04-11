extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.refill_power_full()
		body.add_score(1)

		var level = get_tree().current_scene

		queue_free()

		if level and level.has_method("spawn_battery"):
			level.call_deferred("spawn_battery")
