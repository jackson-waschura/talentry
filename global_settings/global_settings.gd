extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_back_btn_pressed():
	Global.game_controller.change_gui_scene("main_menu")
