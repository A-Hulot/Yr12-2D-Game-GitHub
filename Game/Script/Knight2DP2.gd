extends CharacterBody2D

signal healthChanged2

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var anim_p = $Animation_Player2
@onready var crouch_raycast1 = $Crouch_RayCast
@onready var crouch_raycast2 = $Crouch_RayCast2
@onready var coyote_timer = $CoyoteTimer
@onready var audio_stream_player_2d_jump = $AudioStreamPlayer2D_Jump
@onready var audio_stream_player_2d_attack = $AudioStreamPlayer2D_Attack
@onready var global = get_node("/root/Global")
@onready var current_hp2: int = max_hp2

@export var max_hp2 = 400

var damage = 20
var is_crouching = false
var is_live = true
var is_attacking = false
var object_above = false
var is_rolling = false
var can_take_damage = true
var double_jump = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	get_node("Animation_Player2").play("Idle")
	anim_p.play("Idle")
	current_hp2 = max_hp2

func _physics_process(delta: float) -> void:
	# Apply gravity if on floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jumping logic
	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump2") and is_live:
			velocity.y = jump_velocity
			audio_stream_player_2d_jump.play()
			double_jump = true
			_immune()
	elif Input.is_action_just_pressed("Jump2") and double_jump:
		velocity.y = jump_velocity
		audio_stream_player_2d_jump.play()
		double_jump = false
		_immune()

	# Reset double jump when on the floor
	if is_on_floor():
		double_jump = true
		_immune()

	# Movement and attacking logic
	if is_live:
		var direction = Input.get_axis("Move_left2", "Move_right2")

		# Set horizontal velocity
		if is_attacking:
			velocity.x = 0
		else:
			if is_crouching:
				velocity.x = direction * speed * 0.5
				anim_p.play("Crouch_Walk" if direction != 0 else "Crouch")
			else:
				velocity.x = direction * speed
				if is_rolling:
					pass
				elif direction != 0:
					anim_p.play("Run")
				else:
					anim_p.play("Idle")

		# Flip the character based on movement direction
		if direction != 0:
			$Knight2D2.scale.x = abs($Knight2D2.scale.x) * direction

		# Handle attack input
		if Input.is_action_just_pressed("Attack2") and not is_attacking:
			_attack()
			audio_stream_player_2d_attack.play()

		if Input.is_action_just_released("Attack2"):
			await anim_p.animation_finished
			_reset_animation()

		# Handle crouch input
		if Input.is_action_just_pressed("Crouch2"):
			_crouch()
		elif Input.is_action_just_released("Crouch2"):
			if _not_under_object():
				_stand()
			else:
				object_above = true

		# Handle roll input
		if Input.is_action_just_pressed("Roll2"):
			if is_attacking == false:
				_roll()
				_immune()

		if Input.is_action_just_released("Roll2"):
			if is_rolling:
				await anim_p.animation_finished
				_stand()
				is_rolling = false
				_immune()

		if object_above and _not_under_object():
			_stand()
			object_above = false
			
	else:
		_death()
	
	# Move the character
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >=0:
		coyote_timer.start()

func _immune():
	if is_rolling == true or double_jump == false:
		can_take_damage = false
	else:
		can_take_damage = true

func _crouch():
	if is_crouching:
		return
	is_crouching = true
	is_rolling = false
	is_attacking = false
	velocity.y = speed * 2

func _stand():
	if is_crouching == false:
		return
	is_crouching = false
	velocity.y = speed

func _attack():
	is_attacking = true
	if is_crouching:
		anim_p.play("Crouch_Attack")
	else:
		anim_p.play("Attack")

func _reset_animation():
	await anim_p.animation_finished
	is_attacking = false
	if is_crouching:
		anim_p.play("Crouch")
	else:
		anim_p.play("RESET")

func _roll():
	can_take_damage = false
	is_crouching = false
	is_attacking = false
	is_rolling = true
	anim_p.play("Roll")

func _on_hit():
	if can_take_damage:
		current_hp2 -= damage
		healthChanged2.emit()
		if current_hp2 <= 0 and is_live:
			_death()

func _die(area):
	if area.has_meta("Sword"):
		_on_hit()
	if area.has_meta("Void"):
		current_hp2 = 0
		if is_live and current_hp2 <= 0:
			_death()

func _death():
	if is_live:
		is_live = false
		anim_p.play("Death")
		velocity.x = 0
		if global.lives2 >= 0:
			global.lives2 -= 1
			_respawn()
			print("died")
		elif global.lives2 < 0:
			_respawn()
			global.lives2 = 3
			print("died died like actually died for reals")

func _not_under_object() -> bool:
	var result = !crouch_raycast1.is_colliding() and !crouch_raycast2.is_colliding()
	return result

func _on_animation_finished(anim_name):
	if anim_name == "Roll":
		can_take_damage = true
		is_rolling = false

func _respawn():
	is_live = true
	current_hp2 = max_hp2
	healthChanged2.emit()
	position = Vector2(964, 281)
	anim_p.play("RESET")
