class_name GameController extends Node

const SCENES = [
    "global_settings",
    "main_menu",
    "project_menu",
    "project_options",
    "project_selector",
    "skill_editor",
    "tree_viewer",
    "tree_viewer_gui"
]

signal transition_scene(scene: String)

@export
var world_2d: Node2D
@export
var gui: CanvasLayer

var current_world_2d_scene
var current_gui_scene

func _ready() -> void:
    Global.game_controller = self
    current_gui_scene = $GUI/MainMenu

func clear_2d_scene():
    current_world_2d_scene.queue_free()
    current_world_2d_scene = null

func change_2d_scene(scene: String, delete: bool = true, keep_running: bool = false) -> void:
    assert(scene in SCENES)
    var scene_path = "res://" + scene + "/" + scene + ".tscn"
    if current_world_2d_scene != null:
        if delete:
            current_world_2d_scene.queue_free()  # Removes node entirely
        elif keep_running:
            current_world_2d_scene.visible = false  # Keeps in memory and running
        else:
            world_2d.remove_child(current_world_2d_scene)  # Keeps in memory but doesn't run
    var new = load(scene_path).instantiate()
    world_2d.add_child(new)
    current_world_2d_scene = new

func clear_gui_scene():
    current_gui_scene.queue_free()
    current_gui_scene = null

func change_gui_scene(scene: String, delete: bool = true, keep_running: bool = false) -> void:
    assert(scene in SCENES)
    var scene_path = "res://" + scene + "/" + scene + ".tscn"
    if current_gui_scene != null:
        if delete:
            current_gui_scene.queue_free()  # Removes node entirely
        elif keep_running:
            current_gui_scene.visible = false  # Keeps in memory and running
        else:
            gui.remove_child(current_gui_scene)  # Keeps in memory but doesn't run
    var new = load(scene_path).instantiate()
    gui.add_child(new)
    current_gui_scene = new
