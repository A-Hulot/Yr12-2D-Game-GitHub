class_name Options
extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button
@onready var settings_tab_container = $MarginContainer/VBoxContainer/Settings_Tab_Container

signal exit_options_menu


func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	settings_tab_container.Exit_Options_Menu.connect(on_exit_pressed)
	set_process(false)


# Emits a ecit signal.
func on_exit_pressed():
	exit_options_menu.emit()
	set_process(false)
