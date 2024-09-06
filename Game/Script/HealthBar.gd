extends TextureProgressBar

@export var player: CharacterBody2D

func _ready():
	_update()
	player.healthChanged.connect(_update)

func _process(_delta):
	pass

func _update():
	value = player.current_hp * 100/ player.max_hp
