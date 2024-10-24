extends CharacterBody2D

signal healthChanged

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var MAX_HP = 400

@onready var anim_p = $Animation_Player1
@onready var crouch_raycast1 = $Crouch_RayCast
@onready var crouch_raycast2 = $Crouch_RayCast2
@onready var coyote_timer = $CoyoteTimer
@onready var audio_stream_player_2d_jump = $AudioStreamPlayer2D_Jump
@onready var audio_stream_player_2d_attack = $AudioStreamPlayer2D_Attack
@onready var flash_timer = $Knight2D/flashTimer
@onready var global = get_node("/root/Global")
@onready var dust = preload("res://Scene/Dust.tscn")
@onready var current_hp: int = MAX_HP

var damage = 20
var is_crouching = false
var is_live = true
var is_attacking = false
var object_above = false
var is_rolling = false
var can_take_damage = true
var double_jump = true
var is_grounded = true
var is_knockback = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Plays idle animation on game start and resets their health to max.
func _ready():
	get_node("Animation_Player1").play("Idle")
	anim_p.play("Idle")
	current_hp = MAX_HP
	$Knight2D.material.set_shader_parameter("flash_modifier", 0)


func _physics_process(delta: float) -> void:
	# Plays a dust kick up animation when player lands on the ground.
	if is_grounded == false and is_on_floor() == true:
		var instance = dust.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
		
	is_grounded = is_on_floor()

	# Apply gravity if not on the floor.
	if not is_on_floor():
		velocity.y += gravity * delta

	# If the player is on the floor or there is coyote time remaining, they are able to jump.
	if is_on_floor() or coyote_timer.time_left > 0.0:
		# Checks if they are alive and are able to move, then allows to jump when input pressed.
		if Input.is_action_just_pressed("Jump") and is_live and global.canmove == true:
			velocity.y = jump_velocity
			audio_stream_player_2d_jump.play()
			double_jump = true
			_immune()
	# Double jumps if the player isn't on the floor and they are able to double jump.
	elif Input.is_action_just_pressed("Jump") and double_jump:
		velocity.y = jump_velocity
		audio_stream_player_2d_jump.play()
		double_jump = false
		_immune()

	# Reset double jump when on the floor
	if is_on_floor():
		double_jump = true
		_immune()

	# Movement logic for player.
	if is_live and not is_knockback:
		# Checks if the player is allowed to move at the time.
		if global.canmove == true:
			var direction = Input.get_axis("Move_left", "Move_right")

			# Set horizontal velocity for each of the movement animations.
			if is_attacking:
				velocity.x = 0
			else:
				# If the player is crouching, their horizontal speed decreases and then plays the crouching animations.
				if is_crouching:
					velocity.x = direction * speed * 0.5
					anim_p.play("Crouch_Walk" if direction != 0 else "Crouch")
				# If the player isn't crouching, thier speed is normal.
				else:
					velocity.x = direction * speed
					# If the player is rolling, their speed doubles.
					if is_rolling:
						velocity.x = direction * speed * 2
					# If not rolling and moving, the animation will play the run animation.
					elif direction != 0:
						anim_p.play("Run")
					# If not moving and not rolling, the animation will play the idle animation.
					else:
						anim_p.play("Idle")

			# Flips the character based on movement direction
			if direction != 0:
				$Knight2D.scale.x = abs($Knight2D.scale.x) * direction

		# Checks if the player is trying to attack and isn't currently rolling or attacking.
		if Input.is_action_just_pressed("Attack") and not is_attacking and not is_rolling:
			_attack()
			audio_stream_player_2d_attack.play()
			await anim_p.animation_finished
			is_attacking = false

		# Checks if the player is no longer attacking then resets their character.
		if Input.is_action_just_released("Attack") and not is_attacking:
			_reset_animation()

		# Handle crouch input
		if Input.is_action_just_pressed("Crouch"):
			_crouch()
		elif Input.is_action_just_released("Crouch"):
			# Checks if the player isn't under an object.
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

		# Checks if the character is not under an object
		if object_above and _not_under_object():
			_stand()
			object_above = false

	elif not is_live:
		_death()

	# Knockback
	if is_knockback:
		velocity.x = lerp(velocity.x, 0.0, 2 * delta)
		if abs(velocity.x) < 50:
			is_knockback = false

	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >= 0.0:
		coyote_timer.start()


# Makes it so the player is immune to damage when rolling or double jumping.
func _immune():
	if is_rolling == true or double_jump == false:
		can_take_damage = false
	else:
		can_take_damage = true


# Sets the player to crouching state if isn't already crouching and also sets other states to false.
func _crouch():
	if is_crouching:
		return
	is_crouching = true
	is_rolling = false
	is_attacking = false
	velocity.y = speed * 2


# Standing logic which sets croucing to false if it's not already false and then enables player to take damage.
func _stand():
	if is_crouching == false:
		return
	is_crouching = false
	can_take_damage = true
	velocity.y = speed


# Attacking logix which sets attacking to true and then plays animations based on them standing or crouching.
func _attack():
	is_attacking = true
	if is_crouching:
		anim_p.play("Crouch_Attack")
	else:
		anim_p.play("Attack")


# Resets player animations back to a default.
func _reset_animation():
	is_attacking = false
	if is_crouching:
		anim_p.play("Crouch")
	else:
		anim_p.play("RESET")


# Rolling logic to set variables to true or false and then play the animation as well as disable the player from taking damage.
func _roll():
	is_crouching = false
	is_attacking = false
	is_rolling = true
	can_take_damage = false
	anim_p.play("Roll")


# Sets the knockback power and changed player health depending on whether they are able to take damage.
func _on_hit(dir):
	if can_take_damage == true:
		current_hp -= damage
		healthChanged.emit()
		flash()
		
		velocity.x = 200 * dir
		velocity.y = -250
		is_knockback = true
		
		if current_hp <= 0 and is_live:
			_death()


# Makes the character flash for a certain amount of time when function is called.
func flash():
	$Knight2D.material.set_shader_parameter("flash_modifier", 1)
	flash_timer.start()


# Checks if player has been hit by opponents sword or is in the void and then runs rest of damage logic.
func _damage(area):
	if area.has_meta("Sword2"):
		var dir
		if area.get_node("../..").position.x > position.x:
			dir = -1
		else:
			dir = 1
		_on_hit(dir)
	if area.has_meta("Void"):
		current_hp = 0
		if is_live and current_hp <= 0:
			_death()


# Makes the player die and respawn and plays the animations, also increases opponents score by one.
func _death():
	if is_live:
		is_live = false
		anim_p.play("Death")
		velocity.x = 0
		global.score2 += 1
		await anim_p.animation_finished
		_respawn()


# Checks if the player isn't under an object through the use of raycasts which return a true or false value.
func _not_under_object() -> bool:
	var result = !crouch_raycast1.is_colliding() and !crouch_raycast2.is_colliding()
	return result


# Makes it so after rolling is complete, the player can take damage and sets the player to no longer rolling.
func _on_animation_finished(anim_name):
	if anim_name == "Roll":
		can_take_damage = true
		is_rolling = false


# Resets the player position and hp and then respawns them.
func _respawn():
	is_live = true
	current_hp = MAX_HP
	healthChanged.emit()
	position = Vector2(65, 342)
	anim_p.play("RESET")


# Runs code on the end of the timer for the player flash when they take damage.
func _on_flash_timer_timeout():
	$Knight2D.material.set_shader_parameter("flash_modifier", 0)
