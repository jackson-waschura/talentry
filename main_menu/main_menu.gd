extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_open_project_btn_pressed():
	Global.game_controller.change_gui_scene("project_selector")

func _on_settings_btn_pressed():
	Global.game_controller.change_gui_scene("global_settings")

func _on_exit_btn_pressed():
	get_tree().quit()
