extends Control

signal Exit_Options_Menu

@onready var tab_container = $TabContainer


func _process(_delta):
	options_menu_input()


# Sets the tab to the current tab index
func change_tab(tab : int) -> void:
	tab_container.set_current_tab(tab)


func options_menu_input() -> void:
	# Changes tab to the next one when right arrow pressed.
	if Input.is_action_just_pressed("Move_right") or Input.is_action_just_pressed("Move_right2"):
		if tab_container.current_tab >= tab_container.get_tab_count() - 1:
			change_tab(0)
			return
		
		var next_tab = tab_container.current_tab + 1
		change_tab(next_tab)

	# Changes tab to the next one when left arrow pressed.
	if Input.is_action_just_pressed("Move_left") or Input.is_action_just_pressed("Move_left2"):
		if tab_container.current_tab == 0:
			change_tab(tab_container.get_tab_count() - 1)
		
		var previous_tab = tab_container.current_tab - 1
		change_tab(previous_tab)
