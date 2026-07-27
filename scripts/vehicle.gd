extends VehicleBody3D
## Drivable car. Uses Godot's VehicleWheel3D physics (separate from the
## on-foot controller) so entering/exiting swaps who receives input.

@export var max_engine_force: float = 120.0
@export var max_brake_force: float = 6.0
@export var max_steer_angle: float = 0.6

var driver_inside: bool = false
var exit_marker: Marker3D = null   # where the player is placed after exiting

func _ready() -> void:
	exit_marker = get_node_or_null("ExitPoint")

func _physics_process(_delta: float) -> void:
	if not driver_inside:
		# Idle vehicle: let it settle, no engine input.
		engine_force = 0.0
		brake = 0.2
		return

	engine_force = InputState.throttle * max_engine_force
	brake = max_brake_force if InputState.braking else 0.0
	steering = lerp(steering, -InputState.steer * max_steer_angle, 0.15)

func enter() -> void:
	driver_inside = true

func exit() -> Vector3:
	driver_inside = false
	engine_force = 0.0
	brake = max_brake_force
	if exit_marker:
		return exit_marker.global_position
	return global_position + global_transform.basis.x * 2.0
