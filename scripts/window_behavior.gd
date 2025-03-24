extends Node

var banner_height = 200
var screen_index := 0
var screen_size := Vector2i.ZERO
var screen_position := Vector2i.ZERO

func _ready():
	# Establish Window Behavior
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	
	# Load saved screen index (default to 0 if not found)
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		screen_index = config.get_value("display", "monitor_index", 0)
	
	# Set screen info first, then print it
	set_screen_info(screen_index)
	
	# Set window info based on screen data
	set_window_info()
	
	# Set window size and position after getting the screen data
	DisplayServer.window_set_size(Vector2i(screen_size.x, banner_height))
	DisplayServer.window_set_position(Vector2i(screen_position.x, screen_position.y))

# Function to set and print info about game window
func set_window_info():
	var size = DisplayServer.window_get_size()
	var pos = DisplayServer.window_get_position()
	print("\nWindow size: ", size, "\nWindow position: ", pos)

# Function to set and print info about monitor
func set_screen_info(screen_index: int):
	screen_size = DisplayServer.screen_get_size(screen_index)
	screen_position = DisplayServer.screen_get_position(screen_index)
	print("Monitor: ", screen_index, "\n\nScreen size: ", screen_size, "\nScreen position: ", screen_position)
	
func apply_monitor_change(index: int):
	screen_index = index
	set_screen_info(screen_index)
	set_window_info()

	# Re-apply window size/position
	DisplayServer.window_set_size(Vector2i(screen_size.x, banner_height))
	DisplayServer.window_set_position(Vector2i(screen_position.x, screen_position.y))
