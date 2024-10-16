extends Control

@onready var panel_container = $PanelContainer
@onready var options = $Options
@onready var animation_player = $AnimationPlayer
@onready var button_stream_player = $ButtonStreamPlayer

func _ready():
	animation_player.play("RESET")
	get_tree().paused = false
	handle_connecting_signals()
	options.visible = false

func _process(delta):
	esc()

func resume():
	get_tree().paused = false
	animation_player.play_backwards("blur")

func pause():
	get_tree().paused = true
	animation_player.play("blur")

func esc():
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()


func _on_settings_pressed():
	panel_container.visible = false
	options.visible = true


func _on_exit_game_pressed():
	animation_player.play("RESET")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Menu.tscn")
	
func on_exit_options() -> void:
	options.visible = false
	panel_container.visible = true

func handle_connecting_signals() -> void:
	options.exit_options_menu.connect(on_exit_options)


