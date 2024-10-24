class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

# Exported variable for assigning action names.
@export var action_name : String = "Move_left"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()


# Sets the label text according to the action name.
func set_action_name() -> void:
	# Shows default as "Unassigned" if no action.
	label.text = "Unassigned"
	
	# Matches the action name to update the label text for Player 1 and 2 controls.
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
		"Roll":
			label.text = "Roll (Player 1)"
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
		"Roll2":
			label.text = "Roll (Player 2)"


# Updates the button's text to show the current key binding for the action.
func set_text_for_key() -> void:
	# Gets all inputs events bound to the action_name.
	var action_events = InputMap.action_get_events(action_name)
	# Takes the first event.
	var action_event = action_events[0]
	# Converts the keycode to a readable string (e.g, "A", "Space", etc.).
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)

	# Sets the button's text to show the current keybind.
	button.text = "%s" %action_keycode


# Called when the button is toggled.
func _on_button_toggled(button_pressed):
	if button_pressed:
		button.text = "Press any key..."
		# Enables unhandled key input processing to detect the next key pressed.
		set_process_unhandled_key_input(button_pressed)
		
		# Disables rebinding on all other HotKeyRebindButtons while this one is active.
		for i in get_tree().get_nodes_in_group("hotkey.button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
		
	else:
		# Re-enables rebinding on all other buttons after the process is done.
		for i in get_tree().get_nodes_in_group("hotkey.button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		
		# Resets the button's text to show the current key.
		set_text_for_key()


func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false


# Rebinds the action to the new key pressed by the end-user.
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
