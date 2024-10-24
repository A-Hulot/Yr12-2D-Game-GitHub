extends TextureProgressBar

@export var player: CharacterBody2D


# Upates the player's health
func _ready():
	_update()
	player.healthChanged.connect(_update)


func _process(_delta):
	pass


# Changes the player health to their new health which is then shown on health bar.
func _update():
	value = player.current_hp * 100/ player.MAX_HP
