extends Node2D

@onready var line: Line2D = %Line2D
var start_node: Node2D
var end_node: Node2D


func setup(parent_talent_node, child_talent_node):
    # Ensure the nodes passed are valid TalentNode instances and have the anchors
    if not parent_talent_node or not parent_talent_node.has_node("child_anchor"):
        printerr("Edge setup failed: Invalid parent talent node or missing child_anchor")
        return
    if not child_talent_node or not child_talent_node.has_node("parent_anchor"):
        printerr("Edge setup failed: Invalid child talent node or missing parent_anchor")
        return
        
    start_node = parent_talent_node.get_node("child_anchor")
    end_node = child_talent_node.get_node("parent_anchor")

func update_points():
    # Check if nodes are still valid before accessing their properties
    if is_instance_valid(start_node):
        line.points[0] = start_node.global_position - self.global_position
    if is_instance_valid(end_node):
        line.points[1] = end_node.global_position - self.global_position

func _ready():
    update_points()

func _process(_delta):
    update_points()
