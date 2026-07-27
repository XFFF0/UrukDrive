extends CanvasLayer
## Virtual joystick (left) for movement/steering, drag zone (right) for
## camera look, plus throttle/brake/interact buttons. Writes into the
## InputState autoload every frame so gameplay scripts stay input-agnostic.

@onready var move_joystick: Control = $MoveJoystick
@onready var move_knob: Control = $MoveJoystick/Knob
@onready var look_zone: Control = $LookZone
@onready var throttle_btn: TouchScreenButton = $ThrottleButton
@onready var brake_btn: TouchScreenButton = $BrakeButton
@onready var interact_btn: TouchScreenButton = $InteractButton

var move_touch_index: int = -1
var move_origin: Vector2 = Vector2.ZERO
var look_touch_index: int = -1
var look_last_pos: Vector2 = Vector2.ZERO
const JOYSTICK_RADIUS: float = 60.0

func _ready() -> void:
	interact_btn.pressed.connect(func(): InputState.interact_pressed = true)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if move_joystick.get_global_rect().has_point(event.position) and move_touch_index == -1:
			move_touch_index = event.index
			move_origin = event.position
		elif look_zone.get_global_rect().has_point(event.position) and look_touch_index == -1:
			look_touch_index = event.index
			look_last_pos = event.position
	else:
		if event.index == move_touch_index:
			move_touch_index = -1
			InputState.move_vector = Vector2.ZERO
			InputState.steer = 0.0
			move_knob.position = Vector2.ZERO
		elif event.index == look_touch_index:
			look_touch_index = -1
			InputState.look_vector = Vector2.ZERO

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == move_touch_index:
		var delta_vec: Vector2 = event.position - move_origin
		delta_vec = delta_vec.limit_length(JOYSTICK_RADIUS)
		move_knob.position = delta_vec
		var normalized: Vector2 = delta_vec / JOYSTICK_RADIUS
		InputState.move_vector = normalized
		InputState.steer = clamp(normalized.x, -1.0, 1.0)
	elif event.index == look_touch_index:
		var diff: Vector2 = event.position - look_last_pos
		look_last_pos = event.position
		InputState.look_vector = diff * 0.05

func _process(_delta: float) -> void:
	InputState.throttle = 1.0 if throttle_btn.is_pressed else 0.0
	InputState.braking = brake_btn.is_pressed
