extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player") and body.is_dashing:
		body.reset_dash()
		queue_free()
