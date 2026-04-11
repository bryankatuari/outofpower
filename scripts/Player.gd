extends CharacterBody2D

@onready var power_bar = get_node("../UI/PowerBar")
@onready var anim = $AnimatedSprite2D

@export var speed = 200
@export var jump_force = -400
@export var gravity = 900

@export var dash_speed = 1000
@export var dash_duration = 0.2
@export var dash_cooldown = 0.5

@export var max_power = 100.0
@export var power_drain_per_second = 15.0
@export var power_restore_on_kill = 25.0

var is_dashing = false
var can_dash = true
var is_dead = false

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

var power = 100.0
var facing_right = true

func _ready():
	power = max_power

func _physics_process(delta):
	if is_dead:
		return
	update_ui()
	drain_power(delta)

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
			reset_sprite_rotation()

		update_animation()
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if direction < 0:
		facing_right = false
	elif direction > 0:
		facing_right = true

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	if can_dash and dash_cooldown_timer <= 0:
		if Input.is_action_just_pressed("dash_left"):
			start_dash(Vector2.LEFT)
		elif Input.is_action_just_pressed("dash_right"):
			start_dash(Vector2.RIGHT)
		elif Input.is_action_just_pressed("dash_up"):
			start_dash(Vector2.UP)
		elif Input.is_action_just_pressed("dash_down") and not is_on_floor():
			start_dash(Vector2.DOWN)

	update_facing()
	update_animation()
	move_and_slide()

func start_dash(direction):
	is_dashing = true
	can_dash = false
	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	velocity = Vector2.ZERO
	set_dash_sprite_rotation(direction)

func reset_dash():
	can_dash = true
	dash_cooldown_timer = 0.0

func drain_power(delta):
	power -= power_drain_per_second * delta
	power = clamp(power, 0.0, max_power)

	if power <= 0:
		die()

func die():
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	is_dashing = false
	
	anim.rotation_degrees = 0
	anim.play("death")
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func restore_power(amount):
	power += amount
	power = clamp(power, 0.0, max_power)

func update_ui():
	if power_bar:
		power_bar.max_value = max_power
		power_bar.value = power

func update_facing():
	if is_dashing and (dash_direction == Vector2.UP or dash_direction == Vector2.DOWN):
		return

	anim.flip_h = not facing_right

func update_animation():
	if is_dashing:
		anim.play("dash_attack")
		return

	if not is_on_floor():
		anim.play("jump")
		return

	if abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")

func set_dash_sprite_rotation(direction):
	if direction == Vector2.UP:
		anim.flip_h = false
		anim.rotation_degrees = -90
	elif direction == Vector2.DOWN:
		anim.flip_h = false
		anim.rotation_degrees = 90
	else:
		anim.rotation_degrees = 0
		anim.flip_h = not facing_right

func reset_sprite_rotation():
	anim.rotation_degrees = 0
	anim.flip_h = not facing_right
