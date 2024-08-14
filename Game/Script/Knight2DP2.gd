extends CharacterBody2D

signal healthChanged2

@export var speed = 300.0
@export var jump_velocity = -400.0
@onready var death_timer2 = $DeathTimer2
@onready var anim_p = $Animation_Player2
@onready var crouch_raycast1 = $Crouch_RayCast
@onready var crouch_raycast2 = $Crouch_RayCast2
@onready var coyote_timer = $CoyoteTimer

@export var max_hp2 = 400
@onready var current_hp2: int = max_hp2

var damage = 50
var is_crouching = false
var is_live = true
var is_attacking = false
var object_above = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	get_node("Animation_Player2").play("Idle")
	anim_p.play("Idle")
	current_hp2 = max_hp2

func _physics_process(delta):
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump2") and is_live:
			velocity.y = jump_velocity

	# Checks if the player is alive, if not alive, plays death animation and starts death timer
	if is_live == true:
		var direction = Input.get_axis("Move_left2", "Move_right2")
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
				
		if Input.is_action_just_pressed("Attack2"):
			_attack()
				
		if Input.is_action_just_released("Attack2"):
				_reset_animation()
			
		if Input.is_action_just_pressed("Crouch2"):
			_crouch()
		elif Input.is_action_just_released("Crouch2"):
			if _not_under_object():
				_stand()
			else:
				object_above = true
		
		if object_above and _not_under_object():
			_stand()
			object_above = false
			
	else:
		_death()
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >=0:
		coyote_timer.start()

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
	healthChanged2.emit()
	if current_hp2 <= 0 and is_live:
		_death()

# Detects for spike then sets the player to not alive and starts a death timer
func _die(area):
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

func _not_under_object() -> bool:
	var result = !crouch_raycast1.is_colliding() and !crouch_raycast2.is_colliding()
	return result
	
