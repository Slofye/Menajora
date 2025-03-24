extends Node2D

@onready var settings_button = $SettingsUI/SettingsButton
@onready var settings_menu = $SettingsUI/SettingsMenu

func _ready():
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_menu.hide()  # Ensure it starts hidden

func _on_settings_button_pressed():
	settings_menu.visible = !settings_menu.visible  # Toggle visibility
