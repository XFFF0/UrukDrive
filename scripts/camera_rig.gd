extends Node3D
## Wraps a SpringArm3D + Camera3D. Call follow(target) to snap the rig onto
## either the player or the vehicle. Right-side screen drag orbits the camera
## (fed in through InputState.look_vector by touch_controls.gd).

@export var follow_height: float = 1.6
@export var orbit_sensitivity: float = 2.0
@export var smoothing: float = 8.0

var target: Node3D = null
var yaw: float = 0.0
var pitch: float = -0.3

@onready var spring_arm: SpringArm3D = $SpringArm3D

func follow(new_target: Node3D) -> void:
	target = new_target

func _process(delta: float) -> void:
	if target == null:
		return

	yaw -= InputState.look_vector.x * orbit_sensitivity * delta
	pitch = clamp(pitch - InputState.look_vector.y * orbit_sensitivity * delta, -0.9, 0.2)

	var desired_pos: Vector3 = target.global_position + Vector3(0, follow_height, 0)
	global_position = global_position.lerp(desired_pos, smoothing * delta)
	rotation.y = yaw
	spring_arm.rotation.x = pitch
