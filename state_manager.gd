extends Node

# --- Signals ---
signal enter_edit_tree_mode
signal exit_edit_tree_mode

# --- State Variables ---
var is_editing_tree: bool = false

# --- State Management Functions ---
func toggle_edit_tree_mode():
	if is_editing_tree:
		is_editing_tree = false
		exit_edit_tree_mode.emit()
	else:
		is_editing_tree = true
		enter_edit_tree_mode.emit()

func set_edit_tree_mode(edit_enabled: bool):
	if edit_enabled != is_editing_tree:
		is_editing_tree = edit_enabled
		if is_editing_tree:
			enter_edit_tree_mode.emit()
		else:
			exit_edit_tree_mode.emit()