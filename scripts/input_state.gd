extends Node
## Autoload singleton (registered as "InputState"). Bridges on-screen touch
## controls with gameplay scripts.

var move_vector: Vector2 = Vector2.ZERO
var look_vector: Vector2 = Vector2.ZERO
var throttle: float = 0.0
var braking: bool = false
var steer: float = 0.0
var interact_pressed: bool = false
var fire_pressed: bool = false

func consume_interact() -> bool:
	if interact_pressed:
		interact_pressed = false
		return true
	return false

func consume_fire() -> bool:
	if fire_pressed:
		fire_pressed = false
		return true
	return false

var objective_distance: float = -1.0
