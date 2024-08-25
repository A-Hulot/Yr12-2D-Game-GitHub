class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button


@export var action_name : String = "Move_left"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()


func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"Move_left":
			label.text = "Move Left (Player 1)"
		"Move_right":
			label.text = "Move Right (Player 1)"
		"Jump":
			label.text = "Jump (Player 1)"
		"Crouch":
			label.text = "Crouch (Player 1)"
		"Attack":
			label.text = "Attack (Player 1)"
		"Move_left2":
			label.text = "Move Left (Player 2)"
		"Move_right2":
			label.text = "Move Right (Player 2)"
		"Jump2":
			label.text = "Jump (Player 2)"
		"Crouch2":
			label.text = "Crouch (Player 2)"
		"Attack2":
			label.text = "Attack (Player 2)"


func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)

	button.text = "%s" %action_keycode


func _on_button_toggled(button_pressed):
	if button_pressed:
		button.text = "Press any key..."
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group("hotkey.button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
		
	else:
		
		for i in get_tree().get_nodes_in_group("hotkey.button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		
		set_text_for_key()


func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false


func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()

