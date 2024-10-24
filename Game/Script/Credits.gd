extends Control

signal exit_credits_menu

@onready var exit_button = $Exit_Button


# Connects the exit button to button pressed function.
func _ready():
	exit_button.button_down.connect(exit_button_pressed)
	set_process(false)


# Emits exit signal.
func exit_button_pressed() -> void:
	exit_credits_menu.emit()
	set_process(false)
	
