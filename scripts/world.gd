extends Node3D
## Root script for World.tscn. Wires the camera to whichever the player is
## currently controlling, handles enter/exit vehicle, a simple forward-fire
## weapon, and a minimal "reach the marked point" mission loop.

@onready var player: CharacterBody3D = $Player
@onready var vehicle: VehicleBody3D = $Vehicle
@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D
@onready var mission_marker: Node3D = $MissionMarker

var in_vehicle: bool = false
const ENTER_DISTANCE: float = 3.0
const FIRE_RANGE: float = 60.0

func _ready() -> void:
	player.camera_rig = camera_rig
	camera_rig.follow(player)
	_place_new_mission()

func _process(_delta: float) -> void:
	_handle_enter_exit()
	_handle_fire()
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

func _handle_fire() -> void:
	if not InputState.consume_fire():
		return

	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z).normalized() * FIRE_RANGE
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [player, vehicle]
	var result: Dictionary = space_state.intersect_ray(query)

	var hit_point: Vector3 = to
	if result:
		hit_point = result["position"]
		_spawn_hit_marker(hit_point, result.get("normal", Vector3.UP))

	_spawn_tracer(from, hit_point)

func _spawn_hit_marker(pos: Vector3, normal: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	marker.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.1)
	marker.material_override = mat
	add_child(marker)
	marker.global_position = pos + normal * 0.05
	_auto_free(marker, 2.5)

func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	var tracer := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	var length: float = from.distance_to(to)
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	mesh.height = length
	tracer.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.9, 0.4, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tracer.material_override = mat
	add_child(tracer)
	tracer.global_position = (from + to) * 0.5
	tracer.look_at_from_position(tracer.global_position, to, Vector3.UP)
	tracer.rotate_object_local(Vector3.RIGHT, PI / 2.0)
	_auto_free(tracer, 0.08)

func _auto_free(node: Node, seconds: float) -> void:
	var timer := get_tree().create_timer(seconds)
	timer.timeout.connect(func(): if is_instance_valid(node): node.queue_free())

func _check_mission_progress() -> void:
	var driver: Node3D = vehicle if in_vehicle else player
	InputState.objective_distance = driver.global_position.distance_to(mission_marker.global_position)
	if InputState.objective_distance < 4.0:
		_place_new_mission()

func _place_new_mission() -> void:
	var x: float = randf_range(-55.0, 55.0)
	var z: float = randf_range(-55.0, 55.0)
	mission_marker.global_position = Vector3(x, 0.5, z)
