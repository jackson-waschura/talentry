extends Node2D

var node_blueprint = preload("res://tree_viewer/talent_node.tscn")
var edge_blueprint = preload("res://tree_viewer/edge.tscn")
var tree: ProjectDataManager._Tree
var nodes: Dictionary = {}
var talents: Dictionary = {}
var edges: Array = []
@onready var talent_container = %Talents
@onready var edge_container = %Edges
@onready var camera = %Camera2D

var is_panning = false
var target_camera_position: Vector2 = Vector2.ZERO
const CAMERA_LERP_SPEED: float = 8.0
const CAMERA_MOVE_SPEED: float = 1200.0 # Px/sec

func _ready():
    target_camera_position = camera.position
    setup_talent_tree()

func setup_talent_tree():
    tree = ProjectDataManager.get_active_tree()
    if tree == null:
        printerr("TreeViewer: No active tree found in ProjectDataManager.")
        return

    # Clear existing nodes and edges (if any were previously created)
    for edge in edges:
        edge.queue_free()
    edges = []
    for node_name in nodes:
        nodes[node_name].queue_free()
    nodes = {}
    talents = {}

    # Instantiate nodes and position them
    for talent in tree.talents:
        talents[talent.name] = talent
        var node = node_blueprint.instantiate()
        node.setup(talent)
        node.position = Vector2(talent.x, talent.y)
        nodes[talent.name] = node
        talent_container.add_child(node)

    # Add edges for all nodes
    for talent_name in nodes:
        var talent = talents[talent_name]
        for c_name in talent.children:
            if not nodes.has(c_name):
                printerr("Error creating edge: Child node '%s' not found for parent '%s'" % [c_name, talent_name])
                continue
            var edge = edge_blueprint.instantiate()
            edge.setup(nodes[talent_name], nodes[c_name])
            edges.append(edge)
            edge_container.add_child(edge)

func _process(delta):
    # Check if any GUI element has focus
    var focused_control = get_viewport().gui_get_focus_owner()

    if not is_panning:
        # Handle arrow key input only when not panning AND no GUI element has focus
        if focused_control == null:
            var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
            if input_direction != Vector2.ZERO:
                target_camera_position += input_direction * CAMERA_MOVE_SPEED * delta

        # Smoothly move the camera towards the target position
        camera.position = camera.position.lerp(target_camera_position, clamp(CAMERA_LERP_SPEED * delta, 0.0, 1.0))
    else:
        # While panning, keep the target synced with the actual position
        # to prevent jumps when panning stops.
        target_camera_position = camera.position

func _unhandled_input(event):
    # Handle panning with the left mouse button
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                is_panning = true
                target_camera_position = camera.position
            else:
                if is_panning:
                    is_panning = false
                    target_camera_position = camera.position

func _unhandled_key_input(event):
    if not StateManager.is_editing_tree:
        return
    
    if event is InputEventKey:
        if event.pressed:
            if event.keycode == KEY_A:
                print("Add a new talent at the location of the mouse")
                # Add a new talent at the location of the mouse
                # var talent = ProjectDataManager.create_talent(tree.name, "New Talent", 0, 0)
                # nodes[talent.name].setup(talent)
                # nodes[talent.name].position = camera.position
                # talent_container.add_child(nodes[talent.name])
                # ProjectDataManager.project_updated.emit()
            if event.keycode == KEY_D:
                print("Delete talent or edge at the location of the mouse")
                # Delete the talent or edge at the location of the mouse
                # TODO implement
                # ProjectDataManager.project_updated.emit()
            if event.keycode == KEY_C:
                print("Enter add child mode, allowing the user to add edges from talent to child talent")
                # TODO: Enter add child mode, allowing the user to add edges from talent to child talent
    
func _input(event):
    if event is InputEventMouseMotion and is_panning:
        # Move the camera directly when panning
        camera.position -= event.relative
        # Since we are actively panning, consume the mouse motion event
        get_viewport().set_input_as_handled()
