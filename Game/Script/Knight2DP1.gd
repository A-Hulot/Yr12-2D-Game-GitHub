extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var death_timer = $DeathTimer
	
var is_crouching = false
var is_live = true

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
		
		if direction != 0:
			$Knight2DP1.scale.x = abs($Knight2DP1.scale.x) * direction
			
		# Handles movement and animation based on whether character is crouching
		if is_crouching:
			if direction != 0: # Chekcs if the player is moving and crouching
				velocity.x = direction * speed * 0.5 # Changed velocity to half
				#If animation isn't 'Crouch_Attack', plays 'Crouch_Walk'
				if $Knight2DP1.animation != "Crouch_Attack":
					$Knight2DP1.play("Crouch_Walk")
			else:
				# When not moving and crouching
				velocity.x = 0
				# Checks if animation isn't 'Crouch_Attack', plays 'Crouch' animation
				if $Knight2DP1.animation != "Crouch_Attack":
					$Knight2DP1.play("Crouch")
		else: # If not crouching, animation for character when standing
			if direction != 0: 
				velocity.x = direction * speed
				if $Knight2DP1.animation != "Attack":
					$Knight2DP1.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				if $Knight2DP1.animation != "Attack":
					$Knight2DP1.play("Idle")
				
		
		if Input.is_action_just_pressed("Space"):
			if is_crouching:
				$Knight2DP1.play("Crouch_Attack")
			else:
				$Knight2DP1.play("Attack")
		elif Input.is_action_just_released("Space"):
			if is_crouching:
				$Knight2DP1.play("Crouch")
			else:
				$Knight2DP1.play("Idle")

		if Input.is_action_just_pressed("S"):
			_crouch()
		elif Input.is_action_just_released("S"):
			_stand()

		move_and_slide()
	else:
		$Knight2DP1.play("Death")
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

func _die(area):
	if area.has_meta("Spike"):
		is_live = false
		death_timer.start(0.6)
		
func _on_death_timer_timeout():
	get_tree().reload_current_scene()
