extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var death_timer2 = $DeathTimer2
@onready var anim_p = $Animation_Player2

var max_hp2 = 400
var current_hp2
var is_crouching = false
var is_live = true
var is_attacking = false
var damage = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	get_node("Animation_Player2").play("Idle")
	current_hp2 = max_hp2

func _physics_process(delta):
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Arrow_Up") and is_on_floor() and is_live:
		velocity.y = jump_velocity
	
	# Checks if the player is alive, if not alive, plays death animation and starts death timer
	if is_live == true:
		var direction = Input.get_axis("Arrow_Left", "Arrow_Right")
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
			$Knight2D2.scale.x = abs($Knight2D2.scale.x) * direction
			
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
				
		if Input.is_action_just_pressed("Shift"):
			_attack()
				
		if Input.is_action_just_released("Shift"):
				_reset_animation()
			
		if Input.is_action_just_pressed("Arrow_Down"):
			_crouch()
		elif Input.is_action_just_released("Arrow_Down"):
			_stand()
	else:
		_death()
	move_and_slide()

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

func _on_hit():
	current_hp2 -= damage
	get_node("HP2").value = int((float(current_hp2) / max_hp2) * 100 )
	if current_hp2 <= 0:
		_death()

# Detects for spike then sets the player to not alive and starts a death timer
func _die(area):
	if area.has_meta("Spike"):
		_death()
	if area.has_meta("Sword"):
		_on_hit()

func _death():
	if is_live:
		is_live = false
		death_timer2.start(0.6)
		anim_p.play("Death")
		velocity.x = 0

# Resets scene when the timer 
func _on_death_timer_2_timeout():
	get_tree().reload_current_scene()
