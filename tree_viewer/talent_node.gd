extends Node2D

signal selected(talent_data: ProjectDataManager._Talent)

var talent_data: ProjectDataManager._Talent
var is_dragging: bool = false
var is_potentially_dragging: bool = false # Track if a drag might be starting
var mouse_offset: Vector2 = Vector2.ZERO
var drag_start_position: Vector2 = Vector2.ZERO # Store initial click position

const DRAG_DEADZONE_THRESHOLD: float = 5.0 # Pixels

@onready var child_anchor = $child_anchor
@onready var parent_anchor = $parent_anchor
@onready var title_label = $title
@onready var input_area = $InputArea

func _ready():
    title_label.text = talent_data.name
    # TODO: Use talent_data to set icon

func setup(data: ProjectDataManager._Talent):
    talent_data = data

func _on_input_area_input_event(_viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            is_potentially_dragging = true
            is_dragging = false
            drag_start_position = get_global_mouse_position()
            # Mark the event as handled temporarily to evaluate for drag vs click
            get_viewport().set_input_as_handled()
        else: # Button released
            if is_potentially_dragging and not is_dragging:
                # This was a click, not a drag that exceeded the deadzone
                selected.emit(talent_data)

            # Reset states on button release
            if is_dragging:
                talent_data.x = global_position.x 
                talent_data.y = global_position.y
                ProjectDataManager.project_updated.emit()

            is_potentially_dragging = false
            is_dragging = false


func _input(event):
    # Handle mouse motion only if a drag *might* be starting or is *already* happening
    if (is_potentially_dragging or is_dragging) and event is InputEventMouseMotion:
        var mouse_pos = get_global_mouse_position()

        if is_potentially_dragging:
            # Check if deadzone is exceeded
            if drag_start_position.distance_to(mouse_pos) > DRAG_DEADZONE_THRESHOLD:
                # Deadzone exceeded, now check if we are in edit mode via StateManager
                if StateManager.is_editing_tree:
                    is_dragging = true # Start the actual drag
                    # Calculate offset *now* that dragging has officially started
                    mouse_offset = mouse_pos - global_position
                # Whether we start dragging or not, the potential drag phase is over
                is_potentially_dragging = false
            # If deadzone not exceeded yet, keep the event handled to prevent panning while checking
            get_viewport().set_input_as_handled()

        # If dragging is active (edit mode was true when deadzone was exceeded)
        if is_dragging:
            # Calculate the raw target position
            var target_pos = mouse_pos - mouse_offset
            # Snap the target position to the grid using ConfigManager
            var grid_size = ConfigManager.grid_size
            var snapped_x = round(target_pos.x / grid_size) * grid_size
            var snapped_y = round(target_pos.y / grid_size) * grid_size
            global_position = Vector2(snapped_x, snapped_y)
            # Mark the event as handled so the TreeViewer doesn't pan
            get_viewport().set_input_as_handled()

