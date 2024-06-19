extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var death_timer = $DeathTimer
@onready var anim_p = $Animation_Player1
	
var is_crouching = false
var is_live = true
var is_attacking = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("W") and is_on_floor() and is_live:
		velocity.y = jump_velocity
	
	# Checks if the player is alive, if not alive, plays death animation and starts death timer
	if is_live == true:
		var direction = Input.get_axis("A", "D")
		velocity.x = move_toward(velocity.x, 0, speed)
		
		if is_attacking == false:
			if is_crouching:
				if direction != 0:
					velocity.x = direction * speed * 0.5
					anim_p.play("Crouch_Walk")
				else:
					anim_p.play("Crouch")
			else: 
				if direction != 0:
					anim_p.play("Run")
				else:
					anim_p.play("Idle")
		
		if direction != 0:
			$Knight2D.scale.x = abs($Knight2D.scale.x) * direction
			
		# Handles movement and animation based on whether character is crouching
		if is_crouching:
			if direction != 0: # Chekcs if the player is moving and crouching
				velocity.x = direction * speed * 0.5 # Changed velocity to half
				#If animation isn't 'Crouch_Attack', plays 'Crouch_Walk'
				if anim_p.current_animation != "Crouch_Attack":
					anim_p.play("Crouch_Walk")
			else:
				# When not moving and crouching
				velocity.x = 0
				# Checks if animation isn't 'Crouch_Attack', plays 'Crouch' animation
				if anim_p.current_animation != "Crouch_Attack":
					anim_p.play("Crouch")
		else: # If not crouching, animation for character when standing
			if direction != 0: 
				velocity.x = direction * speed
				if anim_p.current_animation != "Attack":
					anim_p.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				if anim_p.current_animation != "Attack":
					anim_p.play("Idle")
				
		if Input.is_action_just_pressed("Space"):
			_attack()
				
		if Input.is_action_just_released("Space"):
			_reset_animation()
			
		if Input.is_action_just_pressed("S"):
			_crouch()
		elif Input.is_action_just_released("S"):
			_stand()
		move_and_slide()
	else:
		anim_p.play("Death")
		if death_timer.is_stopped():
			death_timer.start()
		return

# Sets crouching to true or false, default is false
func _crouch():
	if is_crouching:
		return
	is_crouching = true

# Checks if crouching is false
func _stand():
	if is_crouching == false:
		return
	is_crouching = false

# Sets attacking variable so attack animations play then returns it back to default 'false'
func _attack():
	is_attacking = true
	if is_crouching:
		anim_p.play("Crouch_Attack")
	else:
		anim_p.play("Attack")

# Waits for the animaption player to finish then plays the default animations 'idle' & 'crouch' and also resetting the animation hitbox
func _reset_animation():
	await anim_p.animation_finished
	is_attacking = false
	if is_crouching:
		anim_p.play("Crouch")
	else:
		anim_p.play("RESET")

# Detects for spike then sets the player to not alive and starts a death timer
func _die(area):
	if area.has_meta("Spike"):
		is_live = false
		death_timer.start(0.6)

# Resets scene when the timer 
func _on_death_timer_timeout():
	get_tree().reload_current_scene()
