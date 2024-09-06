extends TextureProgressBar

@export var player: CharacterBody2D

func _ready():
	_update()
	player.healthChanged2.connect(_update)

func _process(_delta):
	pass

func _update():
	value = player.current_hp2 * 100/ player.max_hp2
