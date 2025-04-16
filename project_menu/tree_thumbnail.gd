extends VBoxContainer

# TODO: generalize the thumbnail scene to accept an icon texture, text, and on_click method

@onready var label = $Label
var tree: ProjectDataManager._Tree

func setup(input_tree):
    tree = input_tree

func _ready():
    if tree != null:
        label.text = tree.name
    else:
        printerr("Thumbnail failed to setup!")

func _on_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if tree == null:
                printerr("Clicked on uninitialized thumbnail!")
            ProjectDataManager.active_tree = tree
            Global.game_controller.change_2d_scene("tree_viewer")
            Global.game_controller.change_gui_scene("tree_viewer_gui")
