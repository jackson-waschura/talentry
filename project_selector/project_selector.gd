extends Control

var project_details: Array
var popup_open: bool = false
var thumbnail_blueprint = preload("res://project_selector/project_thumbnail.tscn")
@onready var projects_container = %GridContainer
@onready var no_projects_label = %NoProjectsLabel
@onready var disable_panel = %DisablePanel
@onready var popup = %Popup
@onready var pnamebox = %PNameBox
@onready var err_label = %ErrorMessage

func _ready():
    project_details = ProjectDataManager.list_projects()
    
    if len(project_details) == 0:
        no_projects_label.visible = true
    
    for details in project_details:
        var thumbnail = thumbnail_blueprint.instantiate()
        thumbnail.setup(details["name"], details["filename"])
        projects_container.add_child(thumbnail)
    
    # Ensure that the popup is disabled.
    disable_panel.visible = false
    popup.visible = false

func open_popup():
    if popup_open:
        printerr("Attempting to open popup that is already open.")
    err_label.text = ""
    disable_panel.visible = true
    popup.visible = true
    pnamebox.grab_focus()
    popup_open = true

func close_popup():
    if not popup_open:
        printerr("Attempting to close popup that isn't open.")
    disable_panel.visible = false
    popup.visible = false
    popup_open = false

func _on_new_btn_pressed():
    open_popup()

func _on_back_btn_pressed():
    Global.game_controller.change_gui_scene("main_menu")

func _on_accept_btn_pressed():
    var pname: String = pnamebox.text
    
    # First, validate the project name is unique (filename check is implicit in ProjectDataManager)
    var err_msg: String = ""
    var current_projects = ProjectDataManager.list_projects() 
    for details in current_projects:
        if pname == details["name"]:
            err_msg = "Project name already in use, please try another."
            break
    if err_msg != "":
        err_label.text = err_msg
        return

    ProjectDataManager.new_project(pname)
    Global.game_controller.change_gui_scene("project_menu")

func _on_exit_popup_btn_pressed():
    close_popup()
