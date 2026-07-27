extends Control

@onready var label: Label = $MissionLabel
var marker_pos: Vector3 = Vector3.ZERO

func set_marker_hint(pos: Vector3) -> void:
	marker_pos = pos

func _process(_delta: float) -> void:
	var world: Node = get_tree().current_scene
	var driver: Node3D = world.get_node_or_null("Vehicle") if world.get("in_vehicle") else world.get_node_or_null("Player")
	if driver and label:
		var dist: float = driver.global_position.distance_to(marker_pos)
		label.text = "Objective: %.0fm" % dist
