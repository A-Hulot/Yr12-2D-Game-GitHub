extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button

signal exit_credits_menu

func _ready():
	exit_button.button_down.connect(exit_button_pressed)
	set_process(false)

func exit_button_pressed() -> void:
	exit_credits_menu.emit()
	set_process(false)
	
