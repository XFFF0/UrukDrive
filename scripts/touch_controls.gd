extends CanvasLayer
## Fully self-drawn on-screen controls (no texture assets needed):
## left joystick for movement/steering, right-side drag for camera look,
## and drawn circular buttons for throttle/brake/interact/fire.
## Writes into the InputState autoload every frame.

const JOYSTICK_RADIUS: float = 70.0
const BUTTON_RADIUS: float = 55.0

var move_touch_index: int = -1
var move_origin: Vector2 = Vector2.ZERO
var move_knob_offset: Vector2 = Vector2.ZERO

var look_touch_index: int = -1
var look_last_pos: Vector2 = Vector2.ZERO

# Each button: name, center (Vector2, set in _ready from screen size), color, label, held(bool), touch_index
var buttons: Array = []
var overlay: Control = null

func _ready() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	move_origin = Vector2(140, size.y - 160)

	buttons = [
		{"name": "fire", "center": Vector2(size.x - 130, size.y - 320), "color": Color(0.85, 0.25, 0.2, 0.55), "label": "FIRE", "held": false, "touch": -1},
		{"name": "interact", "center": Vector2(size.x - 260, size.y - 260), "color": Color(0.3, 0.6, 0.9, 0.55), "label": "USE", "held": false, "touch": -1},
		{"name": "brake", "center": Vector2(size.x - 130, size.y - 190), "color": Color(0.9, 0.6, 0.15, 0.55), "label": "BRAKE", "held": false, "touch": -1},
		{"name": "throttle", "center": Vector2(size.x - 260, size.y - 130), "color": Color(0.25, 0.75, 0.35, 0.55), "label": "GAS", "held": false, "touch": -1},
	]

	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_on_overlay_draw)
	add_child(overlay)

func _on_overlay_draw() -> void:
	if InputState.objective_distance >= 0.0:
		var font: Font = ThemeDB.fallback_font
		var text: String = "Objective: %.0fm" % InputState.objective_distance
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
		var size: Vector2 = get_viewport().get_visible_rect().size
		overlay.draw_string(font, Vector2((size.x - text_size.x) * 0.5, 40), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(1, 1, 1, 0.9))

	# Joystick base + knob
	overlay.draw_circle(move_origin, JOYSTICK_RADIUS, Color(1, 1, 1, 0.15))
	overlay.draw_circle(move_origin + move_knob_offset, 26.0, Color(1, 1, 1, 0.45))

	# Buttons
	for b in buttons:
		var col: Color = b["color"]
		if b["held"]:
			col.a = min(col.a + 0.3, 0.9)
		overlay.draw_circle(b["center"], BUTTON_RADIUS, col)
		var font: Font = ThemeDB.fallback_font
		var text_size: Vector2 = font.get_string_size(b["label"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		overlay.draw_string(font, b["center"] - text_size * 0.5 + Vector2(0, text_size.y * 0.3), b["label"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 0.9))

func _process(_delta: float) -> void:
	overlay.queue_redraw()
	InputState.throttle = 1.0 if _is_held("throttle") else 0.0
	InputState.braking = _is_held("brake")

func _is_held(name: String) -> bool:
	for b in buttons:
		if b["name"] == name:
			return b["held"]
	return false

func _button_at(pos: Vector2) -> Variant:
	for b in buttons:
		if b["center"].distance_to(pos) <= BUTTON_RADIUS:
			return b
	return null

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		var btn = _button_at(event.position)
		if btn:
			btn["held"] = true
			btn["touch"] = event.index
			if btn["name"] == "interact":
				InputState.interact_pressed = true
			elif btn["name"] == "fire":
				InputState.fire_pressed = true
			return

		if event.position.x < get_viewport().get_visible_rect().size.x * 0.5 and move_touch_index == -1:
			move_touch_index = event.index
			move_origin = event.position
			move_knob_offset = Vector2.ZERO
		elif look_touch_index == -1:
			look_touch_index = event.index
			look_last_pos = event.position
	else:
		for b in buttons:
			if b["touch"] == event.index:
				b["held"] = false
				b["touch"] = -1
		if event.index == move_touch_index:
			move_touch_index = -1
			move_knob_offset = Vector2.ZERO
			InputState.move_vector = Vector2.ZERO
			InputState.steer = 0.0
		elif event.index == look_touch_index:
			look_touch_index = -1
			InputState.look_vector = Vector2.ZERO

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == move_touch_index:
		var delta_vec: Vector2 = (event.position - move_origin).limit_length(JOYSTICK_RADIUS)
		move_knob_offset = delta_vec
		var normalized: Vector2 = delta_vec / JOYSTICK_RADIUS
		InputState.move_vector = normalized
		InputState.steer = clamp(normalized.x, -1.0, 1.0)
	elif event.index == look_touch_index:
		var diff: Vector2 = event.position - look_last_pos
		look_last_pos = event.position
		InputState.look_vector = diff * 0.05
