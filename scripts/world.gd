extends Node3D
## Root script for World.tscn. Wires the camera to whichever the player is
## currently controlling, handles enter/exit vehicle, and runs a minimal
## "drive to the marked point" mission loop as a starting gameplay hook.

@onready var player: CharacterBody3D = $Player
@onready var vehicle: VehicleBody3D = $Vehicle
@onready var camera_rig: Node3D = $CameraRig
@onready var mission_marker: Node3D = $MissionMarker
@onready var hud: Control = $TouchControls/HUD

var in_vehicle: bool = false
const ENTER_DISTANCE: float = 3.0

func _ready() -> void:
	player.camera_rig = camera_rig
	camera_rig.follow(player)
	_place_new_mission()

func _process(_delta: float) -> void:
	_handle_enter_exit()
	_check_mission_progress()

func _handle_enter_exit() -> void:
	if not InputState.consume_interact():
		return

	if in_vehicle:
		var exit_pos: Vector3 = vehicle.exit()
		player.global_position = exit_pos
		player.visible = true
		camera_rig.follow(player)
		in_vehicle = false
	else:
		if player.global_position.distance_to(vehicle.global_position) <= ENTER_DISTANCE:
			vehicle.enter()
			player.visible = false
			camera_rig.follow(vehicle)
			in_vehicle = true

func _check_mission_progress() -> void:
	var driver: Node3D = vehicle if in_vehicle else player
	if driver.global_position.distance_to(mission_marker.global_position) < 4.0:
		_place_new_mission()

func _place_new_mission() -> void:
	# Simple placeholder loop: pick a random point within the blocked-out
	# city so there's always an objective to drive/walk toward.
	var x: float = randf_range(-40.0, 40.0)
	var z: float = randf_range(-40.0, 40.0)
	mission_marker.global_position = Vector3(x, 0.5, z)
	if hud:
		hud.call("set_marker_hint", mission_marker.global_position)
