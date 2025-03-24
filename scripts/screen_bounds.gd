# ScreenBounds.gd
# Global utility to manage screen boundaries and visible viewport logic.
# Handles dynamic screen resizing, spawn/despawn edges, and general edge detection.

extends Node
class_name screen_bounds

# The current visible screen rectangle (auto-updated on resolution/viewport changes)
var rect: Rect2

# Emitted whenever the screen bounds are recalculated (e.g., on window resize)
signal bounds_updated(new_bounds: Rect2)

# Called when node enters the scene tree – sets initial bounds and connects updates
func _ready():
	_update_bounds()
	get_viewport().connect("size_changed", Callable(self, "_update_bounds"))

# Recalculate screen bounds based on the current viewport's visible rectangle
func _update_bounds():
	rect = get_viewport().get_visible_rect()
	print("\nGame Boundaries: ", rect, "\n")
	emit_signal("bounds_updated", rect)

# Returns the position just at or offset from a screen edge (used for spawning/despawning)
# direction: "top", "bottom", "left", "right"
# offset: distance away from the edge (default 0)
func get_edge_position(direction: String, offset := 0.0) -> Vector2:
	match direction:
		"top":
			return Vector2(rect.position.x + rect.size.x / 2, rect.position.y - offset)
		"bottom":
			return Vector2(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y + offset)
		"left":
			return Vector2(rect.position.x - offset, rect.position.y + rect.size.y / 2)
		"right":
			return Vector2(rect.position.x + rect.size.x + offset, rect.position.y + rect.size.y / 2)
		_:
			push_error("Invalid direction passed to get_edge_position(): " + direction)
			return Vector2.ZERO

# Checks if a given global position is currently within the visible screen
func is_inside_screen(pos: Vector2) -> bool:
	return rect.has_point(pos)
