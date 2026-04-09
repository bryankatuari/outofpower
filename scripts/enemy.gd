extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.is_dashing:
			body.reset_dash()
			body.restore_power(body.power_restore_on_kill)
			queue_free()
		else:
			body.die()
