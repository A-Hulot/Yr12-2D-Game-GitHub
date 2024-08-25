extends Node2D

@onready var options = $CanvasLayer/Options

var settings_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()
	options.visible = false
	settings_enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if settings_enabled == false:
		if Input.is_action_just_pressed("Escape"):
			settings_enabled = true
			set_process(true)
			options.visible = true
	elif settings_enabled == true and Input.is_action_just_pressed("Escape"):
		settings_enabled = false
		options.visible = false

func on_exit_options() -> void:
	get_tree().change_scene_to_file("res://Scene/Menu.tscn")

func handle_connecting_signals() -> void:
	options.exit_options_menu.connect(on_exit_options)

