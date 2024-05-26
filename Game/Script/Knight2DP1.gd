extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0
	
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("W") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("A", "D")
	if direction:
		velocity.x = direction * speed
		$Knight2DP1.play("Run")
		$Knight2DP1.scale.x = abs($Knight2DP1.scale.x) * direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		$Knight2DP1.play("Idle")

	move_and_slide()
