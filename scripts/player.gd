extends CharacterBody3D
## Third-person on-foot controller. Movement is relative to the camera rig
## so it feels like a standard open-world character, not a fixed-axis walker.

@export var walk_speed: float = 4.5
@export var run_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 10.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_rig: Node3D = null   # assigned by World.gd so movement can be camera-relative

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir: Vector2 = InputState.move_vector
	var direction: Vector3 = Vector3.ZERO

	if camera_rig:
		var cam_basis: Basis = camera_rig.global_transform.basis
		var forward: Vector3 = -cam_basis.z
		var right: Vector3 = cam_basis.x
		forward.y = 0
		right.y = 0
		direction = (forward.normalized() * -input_dir.y + right.normalized() * input_dir.x)
	else:
		direction = Vector3(input_dir.x, 0, input_dir.y)

	var speed: float = run_speed if input_dir.length() > 0.9 else walk_speed

	if direction.length() > 0.01:
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		var target_angle: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 4 * delta)

	move_and_slide()
