extends Node

# --- Data Structures ---
class _Talent:
    var name: String
    var description: String
    var level_requirements: Array[String] = []
    var level: int
    var max_level: int
    var children: Array[String] = []
    var x: float = 0.0
    var y: float = 0.0

class _Tree:
    var name: String
    var description: String
    var talents: Array[_Talent] = []

class _Project:
    var name: String
    var trees: Array[_Tree] = []

# --- Signals ---
# Consider renaming this later if its usage becomes more specific
signal project_updated

# --- Variables ---
var save_folder: String = "user://projects_talentry"
var project_filename: String = ""
var active_project: _Project
var active_tree: _Tree # Consider if this should live here or be derived/passed

# --- Save Thread ---
var save_thread: Thread

# --- Lifecycle & Initialization ---
func _ready():
    # Ensure save folder exists (Moved from Global._ready)
    if not DirAccess.dir_exists_absolute(save_folder):
        if DirAccess.make_dir_absolute(save_folder) != OK:
            printerr("Unable to create save folder!")
    # TODO: only print if debug is enabled
    print("Save folder: ", ProjectSettings.globalize_path(save_folder))
    
    # Connect the signal to the save function (Moved from Global._ready)
    project_updated.connect(_on_project_updated)

# --- Project Listing ---
func list_projects() -> Array:
    var files = DirAccess.get_files_at(save_folder)
    var project_files = []
    for file in files:
        if file.ends_with(".json"):
            var file_path = save_folder.path_join(file)
            var file_reader = FileAccess.open(file_path, FileAccess.READ)
            if file_reader == null:
                printerr("Failed to open project file for reading name: ", file_path, " Error: ", FileAccess.get_open_error())
                continue
            var json = JSON.new()
            var file_string = file_reader.get_as_text()
            var error = json.parse(file_string)
            if error != OK:
                printerr("Corrupted project file: ", file)
                printerr("JSON Parse Error: ", json.get_error_message(), " in ", file_string, " at line ", json.get_error_line())
                continue
            if json.data.has("name") and typeof(json.data["name"]) == TYPE_STRING:
                project_files.append({"name": json.data["name"], "filename": file.trim_suffix(".json")})
            else:
                printerr("Project file missing or invalid 'name' field: ", file)
    return project_files

# --- Project Creation/Loading ---
func new_project(project_name: String):
    var p = _Project.new()
    p.name = project_name
    active_project = p
    active_tree = null 
    project_filename = project_name.to_snake_case()
    project_updated.emit() 

func load_project(pfilename: String):
    project_filename = pfilename
    var file_path = save_folder.path_join(project_filename + ".json")
    if not FileAccess.file_exists(file_path):
        printerr("Project file not found: ", file_path)
        active_project = null # Ensure project is cleared if load fails
        active_tree = null
        return

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        printerr("Failed to open project file for loading: ", file_path, " Error: ", FileAccess.get_open_error())
        active_project = null
        active_tree = null
        return

    var json = JSON.new()
    var file_string = file.get_as_text()
    file.close() # Close file after reading
    var error = json.parse(file_string)
    if error != OK:
        printerr("JSON Parse Error: ", json.get_error_message(), " in ", file_string, " at line ", json.get_error_line())
        active_project = null
        active_tree = null
        return
    
    var project_data = json.data
    var tmp_project = _Project.new()

    # --- Data Validation ---
    if not project_data.has("name"):
        printerr("Project file is missing name!")
        active_project = null; active_tree = null; return
    tmp_project.name = project_data["name"]

    if not project_data.has("trees") or not typeof(project_data["trees"]) == TYPE_ARRAY:
        printerr("Project trees data is missing or not an array!")
        active_project = null; active_tree = null; return # Potentially allow projects with no trees?

    for tree_data in project_data["trees"]:
        var tree = _Tree.new()
        if not tree_data.has("name") or not typeof(tree_data["name"]) == TYPE_STRING: printerr("Tree is missing name!"); continue
        tree.name = tree_data["name"]
        if not tree_data.has("description") or not typeof(tree_data["description"]) == TYPE_STRING: printerr("Tree '%s' missing description!" % tree.name); continue # Default?
        tree.description = tree_data.get("description", "") # Use get for safety/default
        
        if not tree_data.has("talents") or not typeof(tree_data["talents"]) == TYPE_ARRAY: printerr("Tree '%s' missing talents array!" % tree.name); continue
        
        for talent_data in tree_data["talents"]:
            var talent = _Talent.new()
            if not talent_data.has("name") or not typeof(talent_data["name"]) == TYPE_STRING: printerr("Talent in tree '%s' missing name!" % tree.name); continue
            talent.name = talent_data["name"]
            if not talent_data.has("description") or not typeof(talent_data["description"]) == TYPE_STRING: printerr("Talent '%s' missing description!" % talent.name); continue
            talent.description = talent_data.get("description", "")

            if not talent_data.has("level_requirements") or not typeof(talent_data["level_requirements"]) == TYPE_ARRAY: printerr("Talent '%s' missing level reqs!" % talent.name); continue
            for lreq in talent_data["level_requirements"]:
                if typeof(lreq) == TYPE_STRING: talent.level_requirements.append(lreq)
                else: printerr("Invalid level req '%s' for talent '%s'" % [lreq, talent.name])

            # Simplified level/max_level loading with defaults/type checking
            talent.level = int(talent_data.get("level", 0))
            talent.max_level = int(talent_data.get("max_level", 1))

            if not talent_data.has("children") or not typeof(talent_data["children"]) == TYPE_ARRAY: printerr("Talent '%s' missing children!" % talent.name); continue
            for child_str in talent_data["children"]:
                if typeof(child_str) == TYPE_STRING: talent.children.append(child_str)
                else: printerr("Invalid child '%s' for talent '%s'" % [child_str, talent.name])

            # Simplified position loading with defaults
            talent.x = float(talent_data.get("x", 0.0))
            talent.y = float(talent_data.get("y", 0.0))

            tree.talents.append(talent)
        tmp_project.trees.append(tree)
    
    active_project = tmp_project
    active_tree = null

# --- Active Tree Management ---
func set_active_tree(tree_name: String):
    if active_project == null:
        printerr("Cannot set active tree, no project loaded.")
        active_tree = null
        return

    for tree in active_project.trees:
        if tree.name == tree_name:
            active_tree = tree
            return
    
    printerr("Tree '%s' not found in active project '%s'." % [tree_name, active_project.name])
    active_tree = null

func get_active_tree() -> _Tree:
    return active_tree
    
# --- Data Modification ---
# Add functions here later to modify data (e.g., add_tree, update_talent_position)
# These functions will modify active_project/active_tree and then emit project_updated

# --- Saving Logic ---
func _prepare_save_data() -> Dictionary:
    if active_project == null:
        printerr("Cannot save, no active project.")
        return {}
    if project_filename == "":
        printerr("Cannot save, project filename is empty.")
        return {}
    
    var project_data = {
        "name": active_project.name,
        "trees": []
    }
    for tree in active_project.trees:
        var tree_data = {
            "name": tree.name,
            "description": tree.description,
            "talents": []
        }
        for talent in tree.talents:
            var talent_data = {
                "name": talent.name,
                "description": talent.description,
                "level_requirements": talent.level_requirements,
                "level": talent.level,
                "max_level": talent.max_level,
                "children": talent.children,
                "x": talent.x,
                "y": talent.y
            }
            tree_data["talents"].append(talent_data)
        project_data["trees"].append(tree_data)
    return project_data

func _save_project_thread(project_data: Dictionary):
    if project_data.is_empty():
        printerr("Save thread received empty project data. Aborting save.")
        return

    var temp_file_path = save_folder.path_join(project_filename + ".json.tmp")
    var final_file_path = save_folder.path_join(project_filename + ".json")
    
    var file = FileAccess.open(temp_file_path, FileAccess.WRITE)
    if file == null:
        var err = FileAccess.get_open_error()
        printerr("Failed to open temp file for saving: ", temp_file_path, " Error code: ", err)
        return

    var json_string: String = JSON.stringify(project_data, "  ")
    file.store_string(json_string)
    file.close()

    var dir_access = DirAccess.open(save_folder)
    if dir_access == null:
        printerr("Failed to open save directory for renaming. Error code: ", DirAccess.get_open_error())
        # Attempt to clean up temp file even if dir opening failed
        DirAccess.remove_absolute(temp_file_path) 
        return
        
    # Ensure the directory access is valid before attempting removal/rename
    var rename_error = dir_access.rename(temp_file_path.get_file(), final_file_path.get_file())
    if rename_error != OK:
        printerr("Failed to rename temp save file '%s' to '%s'. Error code: %d" % [temp_file_path.get_file(), final_file_path.get_file(), rename_error])
        dir_access.remove(temp_file_path.get_file())

# Called when project_updated signal is emitted. (Moved from Global)
func _on_project_updated():
    var project_data = _prepare_save_data()
    if project_data.is_empty():
        return

    # Ensure any previous save completes before starting a new one.
    if save_thread != null:
        save_thread.wait_to_finish()

    # Start the save operation in a new thread
    save_thread = Thread.new()
    save_thread.start(_save_project_thread.bind(project_data)) 
