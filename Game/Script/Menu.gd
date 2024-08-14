class_name Menu
extends Control

@onready var play_button = $MarginContainer/HBoxContainer/VBoxContainer/Play_button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/Options_button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_button
@onready var options = $Options
@onready var margin_container = $MarginContainer

@onready var start_level = preload("res://Scene/Level1.tscn")


func _ready():
	handle_connecting_signals()


func on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Level1.tscn")


func on_options_button_pressed() -> void:
	margin_container.visible = false
	options.set_process(true)
	options.visible = true


func on_exit_button_pressed() -> void:
	get_tree().quit()


func on_exit_options() -> void:
	margin_container.visible = true
	options.visible = false

func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_play_button_pressed)
	options_button.button_down.connect(on_options_button_pressed)
	exit_button.button_down.connect(on_exit_button_pressed)
	options.exit_options_menu.connect(on_exit_options)
