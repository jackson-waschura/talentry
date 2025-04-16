extends Control

var thumbnail_blueprint = preload("res://project_menu/tree_thumbnail.tscn")

@onready var title_label = %TitleLabel
@onready var no_trees_label = %NoTreesLabel
@onready var trees_container = %TreesContainer
@onready var disable_panel = %DisablePanel
@onready var popup = %Popup
@onready var tnamebox = %TNameBox
@onready var err_label = %ErrorMessage
var popup_open: bool = false
var thumbnails = []

# Called when the node enters the scene tree for the first time.
func _ready():
    if ProjectDataManager.active_project == null:
        printerr("No project loaded!")
        Global.game_controller.change_gui_scene("project_selector")
    else:
        title_label.text = ProjectDataManager.active_project.name
        setup_thumbnails()
    
    # Ensure that the popup is disabled.
    disable_panel.visible = false
    popup.visible = false

func setup_thumbnails():
    var project = ProjectDataManager.active_project
    if project == null: return
    
    for thumbnail in thumbnails:
        thumbnail.get_parent().remove_child(thumbnail)
        thumbnail.queue_free()
    thumbnails.clear()
    
    if len(project.trees) == 0:
        no_trees_label.visible = true
    else:
        no_trees_label.visible = false
        # Create the Tree Thumbnail Scene
        for tree in project.trees:
            var thumbnail = thumbnail_blueprint.instantiate()
            thumbnail.setup(tree)
            thumbnails.append(thumbnail)
            trees_container.add_child(thumbnail)

func open_popup():
    if popup_open:
        printerr("Attempting to open popup that is already open.")
    err_label.text = ""
    disable_panel.visible = true
    popup.visible = true
    tnamebox.grab_focus()
    popup_open = true

func close_popup():
    if not popup_open:
        printerr("Attempting to close popup that isn't open.")
    disable_panel.visible = false
    popup.visible = false
    popup_open = false

func _on_back_btn_pressed():
    Global.game_controller.change_gui_scene("project_selector")

func _on_new_btn_pressed():
    open_popup()

func _on_accept_btn_pressed():
    var project = ProjectDataManager.active_project
    if project == null: 
        printerr("Cannot add tree, no active project.")
        close_popup()
        return
        
    var new_tree_name = tnamebox.text.strip_edges()
    if new_tree_name == "":
        err_label.text = "Tree name cannot be empty."
        return
        
    # Check if tree name already exists
    for existing_tree in project.trees:
        if existing_tree.name == new_tree_name:
            err_label.text = "A tree with this name already exists."
            return

    # Create the new tree object (using the type defined in ProjectDataManager)
    var new_tree = ProjectDataManager._Tree.new()
    new_tree.name = new_tree_name
    
    # Modify the project data directly (consider a manager function later)
    project.trees.append(new_tree)
    
    # Signal the manager that data has changed to trigger save
    ProjectDataManager.project_updated.emit()
    
    # Refresh UI
    setup_thumbnails()
    close_popup()

func _on_exit_popup_btn_pressed():
    close_popup()
