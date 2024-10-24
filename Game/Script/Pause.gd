extends Control

@onready var panel_container = $PanelContainer
@onready var options = $Options
@onready var animation_player = $AnimationPlayer
@onready var button_stream_player = $ButtonStreamPlayer

var is_resumed = true


func _ready():
	animation_player.play("Renew")
	get_tree().paused = false
	handle_connecting_signals()
	options.visible = false


func _process(_delta):
	esc()


# Resumes the game when called.
func resume():
	get_tree().paused = false
	animation_player.play_backwards("blur")


# Pauses the game when called.
func pause():
	is_resumed = false
	get_tree().paused = true
	animation_player.play("blur")


func esc():
	# Pauses game when escape key is pressed.
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		pause()
		is_resumed = false
	# Resumes game when escape key is pressed again when paused.
	elif Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		resume()
		is_resumed = true



# Resumes game whem pressed.
func _on_resume_button_down():
	if is_resumed == false:
		is_resumed = true
		resume()
		button_stream_player.play()


# Opens settings when pressed.
func _on_settings_button_down():
	panel_container.visible = false
	options.visible = true
	button_stream_player.play()


# Exits game and returns to meu when pressed.
func _on_exit_game_button_down():
	animation_player.play("Renew")
	get_tree().paused = false
	button_stream_player.play()
	get_tree().change_scene_to_file("res://Scene/Menu.tscn")


# Exit options menu.
func on_exit_options() -> void:
	options.visible = false
	panel_container.visible = true
	button_stream_player.play()


# Connects options exit button.
func handle_connecting_signals() -> void:
	options.exit_options_menu.connect(on_exit_options)
