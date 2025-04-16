extends Control

@onready var edit_label: RichTextLabel = %EditLabel
@onready var tree_name: LineEdit = %TreeName
var tree: ProjectDataManager._Tree

func _ready():
    tree = ProjectDataManager.get_active_tree()
    if tree != null:
        tree_name.text = tree.name
    else:
        printerr("TreeViewerGui: No active tree found. Returning to project menu.")
        return_to_project_menu()
        return
    
    StateManager.enter_edit_tree_mode.connect(on_enter_edit_tree_mode)
    StateManager.exit_edit_tree_mode.connect(on_exit_edit_tree_mode)
    
    tree_name.text_submitted.connect(_update_tree_name)
    tree_name.focus_exited.connect(_update_tree_name)
    
    edit_label.visible = StateManager.is_editing_tree

func _update_tree_name(new_name: String = ""):
    if new_name == "":
        new_name = tree_name.text.strip_edges()
    
    if new_name != tree.name and new_name != "":
        tree.name = new_name
        print("Tree name updated to: ", tree.name)
        ProjectDataManager.project_updated.emit()
    elif new_name == "":
        tree_name.text = tree.name
        
    tree_name.release_focus()

func return_to_project_menu():
    Global.game_controller.clear_2d_scene()
    Global.game_controller.change_gui_scene("project_menu")

func _on_back_btn_pressed():
    if StateManager.is_editing_tree:
        StateManager.set_edit_tree_mode(false)
    return_to_project_menu()

func _on_edit_btn_pressed():
    StateManager.toggle_edit_tree_mode()

func on_enter_edit_tree_mode():
    edit_label.visible = true

func on_exit_edit_tree_mode():
    edit_label.visible = false
