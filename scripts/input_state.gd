extends Node
## Autoload singleton (register as "InputState" in Project Settings > Autoload).
## Bridges on-screen touch controls with gameplay scripts, since GTA-style
## mobile games rely on virtual joysticks/buttons rather than a keyboard.

var move_vector: Vector2 = Vector2.ZERO      # from the left virtual joystick
var look_vector: Vector2 = Vector2.ZERO      # from right-side drag (camera look)
var throttle: float = 0.0                    # 0..1 accelerator button
var braking: bool = false                    # brake button held
var steer: float = 0.0                       # -1..1 steering slider
var interact_pressed: bool = false           # enter/exit vehicle button (one-shot)

func consume_interact() -> bool:
	if interact_pressed:
		interact_pressed = false
		return true
	return false
