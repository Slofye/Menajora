extends Control

@onready var monitor_selector: OptionButton = $Margin/VBoxContainer/TabContainer/General/MonitorSelection/HBoxContainer/OptionButton
@onready var exit_game_button: Button = $Margin/VBoxContainer/VBoxContainer/HBoxContainer3/ExitGameButton
@onready var cancel_button: Button = $Margin/VBoxContainer/VBoxContainer/HBoxContainer3/CancelButton
@onready var apply_button: Button = $Margin/VBoxContainer/VBoxContainer/HBoxContainer3/ApplyButton

var selected_monitor_index := DisplayServer.get_primary_screen()
var last_applied_monitor_index := 0



# Called when the node enters the scene tree for the first time.
func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	var saved_index = 0
	if err == OK:
		saved_index = config.get_value("display", "monitor_index", 0)

	var screen_count = DisplayServer.get_screen_count()
	for i in range(screen_count):
		monitor_selector.add_item("Monitor " + str(i + 1), i)

	monitor_selector.select(saved_index)
	selected_monitor_index = saved_index
	last_applied_monitor_index = saved_index


	# Connect signals
	monitor_selector.item_selected.connect(_on_monitor_selected)
	exit_game_button.pressed.connect(_on_exit_game_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	apply_button.pressed.connect(_on_apply_button_pressed)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_monitor_selected(index):
	selected_monitor_index = index  # Just store it, don’t apply yet
	
	# Save the setting
	var config = ConfigFile.new()
	config.set_value("display", "monitor_index", selected_monitor_index)
	config.save("user://settings.cfg")
	
func _on_exit_game_button_pressed() -> void:
	print("\nExiting Game...")
	get_tree().quit()

func _on_cancel_button_pressed() -> void:
	selected_monitor_index = last_applied_monitor_index
	monitor_selector.select(selected_monitor_index)
	print("\nClosing Settings...")
	self.hide()

func _on_apply_button_pressed() -> void:
	DisplayServer.window_set_current_screen(selected_monitor_index)
	WindowBehavior.apply_monitor_change(selected_monitor_index)
	
	last_applied_monitor_index = selected_monitor_index

	var config = ConfigFile.new()

	# Display
	config.set_value("display", "monitor_index", selected_monitor_index)
	# config.set_value("display", "resolution", Vector2i(1280, 720))  # Replace with dropdown value
	# config.set_value("display", "position", Vector2i(0, 0))  # Optional, or use last known

	# Audio
	# config.set_value("audio", "sfx_volume", sfx_slider.value)
	# config.set_value("audio", "music_volume", music_slider.value)
	
	config.save("user://settings.cfg")
