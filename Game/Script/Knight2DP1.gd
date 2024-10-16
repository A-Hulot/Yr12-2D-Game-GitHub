extends CharacterBody2D

signal healthChanged

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var anim_p = $Animation_Player1
@onready var crouch_raycast1 = $Crouch_RayCast
@onready var crouch_raycast2 = $Crouch_RayCast2
@onready var coyote_timer = $CoyoteTimer
@onready var audio_stream_player_2d_jump = $AudioStreamPlayer2D_Jump
@onready var audio_stream_player_2d_attack = $AudioStreamPlayer2D_Attack
@onready var global = get_node("/root/Global")
@onready var dust = preload("res://Scene/Dust.tscn")
@onready var current_hp: int = max_hp
@onready var flash_timer = $Knight2D/flashTimer

@export var max_hp = 400

var damage = 20
var is_crouching = false
var is_live = true
var is_attacking = false
var object_above = false
var is_rolling = false
var can_take_damage = true
var double_jump = true
var is_grounded = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	get_node("Animation_Player1").play("Idle")
	anim_p.play("Idle")
	current_hp = max_hp
	$Knight2D.material.set_shader_parameter("flash_modifier", 0)

func _physics_process(delta: float) -> void:
	
	if is_grounded == false and is_on_floor() == true:
		var instance = dust.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
		
	is_grounded = is_on_floor()
	
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jumping logic
	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump") and is_live and global.canmove == true:
			velocity.y = jump_velocity
			audio_stream_player_2d_jump.play()
			double_jump = true
			_immune()
	elif Input.is_action_just_pressed("Jump") and double_jump:
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
		if global.canmove == true:
			var direction = Input.get_axis("Move_left", "Move_right")

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
				$Knight2D.scale.x = abs($Knight2D.scale.x) * direction

		# Handle attack input
		if Input.is_action_just_pressed("Attack") and not is_attacking:
			_attack()
			audio_stream_player_2d_attack.play()
			await anim_p.animation_finished
			is_attacking = false

		if Input.is_action_just_released("Attack") and not is_attacking:
			_reset_animation()

		# Handle crouch input
		if Input.is_action_just_pressed("Crouch"):
			_crouch()
		elif Input.is_action_just_released("Crouch"):
			if _not_under_object():
				_stand()
			else:
				object_above = true

		# Handle roll input
		if Input.is_action_just_pressed("Roll"):
			if is_attacking == false:
				_roll()
				_immune()

		if Input.is_action_just_released("Roll"):
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
	if was_on_floor and not is_on_floor() and velocity.y >= 0.0:
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
	can_take_damage = true
	velocity.y = speed

func _attack():
	is_attacking = true
	if is_crouching:
		anim_p.play("Crouch_Attack")
	else:
		anim_p.play("Attack")

func _reset_animation():
	is_attacking = false
	if is_crouching:
		anim_p.play("Crouch")
	else:
		anim_p.play("RESET")

func _roll():
	is_crouching = false
	is_attacking = false
	is_rolling = true
	can_take_damage = false
	anim_p.play("Roll")

func _on_hit():
	if can_take_damage == true:
		current_hp -= damage
		healthChanged.emit()
		flash()
		if current_hp <= 0 and is_live:
			_death()

func flash():
	$Knight2D.material.set_shader_parameter("flash_modifier", 1)
	flash_timer.start()

func _die(area):
	if area.has_meta("Sword2"):
		_on_hit()
	if area.has_meta("Void"):
		current_hp = 0
		if is_live and current_hp <= 0:
			_death()

func _death():
	if is_live:
		is_live = false
		anim_p.play("Death")
		velocity.x = 0
		global.score2 += 1
		await anim_p.animation_finished
		if global.lives >= 0:
			global.lives -= 1
			_respawn()
			print("died")
		elif global.lives < 0:
			_respawn()
			global.lives = 3
			global.score2 = 0
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
	current_hp = max_hp
	healthChanged.emit()
	position = Vector2(65, 342)
	anim_p.play("RESET")

func _on_flash_timer_timeout():
	$Knight2D.material.set_shader_parameter("flash_modifier", 0)
