extends TextureProgressBar

@export var player: CharacterBody2D


# Updates player health.
func _ready():
	_update()
	player.healthChanged2.connect(_update)


func _process(_delta):
	pass


# Changes the player health to their new health which is then shown on their health bar.
func _update():
	value = player.current_hp2 * 100/ player.MAX_HP2
