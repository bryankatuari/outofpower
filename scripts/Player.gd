extends CharacterBody2D

@export var speed = 200
@export var jump_force = -400
@export var gravity = 900

@export var dash_speed = 1000
@export var dash_duration = 0.2
@export var dash_cooldown = 0.5

var is_dashing = false
var can_dash = true

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

func _physics_process(delta):
	if is_on_floor():
		reset_dash()

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed

		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO

		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	if can_dash and dash_cooldown_timer <= 0:
		if Input.is_action_just_pressed("dash_left"):
			start_dash(Vector2.LEFT)
		elif Input.is_action_just_pressed("dash_right"):
			start_dash(Vector2.RIGHT)
		elif Input.is_action_just_pressed("dash_up"):
			start_dash(Vector2.UP)
		elif Input.is_action_just_pressed("dash_down"):
			start_dash(Vector2.DOWN)

	move_and_slide()

func start_dash(direction):
	is_dashing = true
	can_dash = false
	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	velocity = Vector2.ZERO

func reset_dash():
	can_dash = true
	dash_cooldown_timer = 0.0
