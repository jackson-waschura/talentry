extends VBoxContainer

@onready var label = $Label
var project_name: String = ""
var project_filename: String = ""

func setup(pname, pfilename):
	project_name = pname
	project_filename = pfilename

func _ready():
	if project_name != "":
		label.text = project_name
	else:
		printerr("Thumbnail failed to setup!")

func _on_v_box_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ProjectDataManager.load_project(project_filename)
			Global.game_controller.change_gui_scene("project_menu")
