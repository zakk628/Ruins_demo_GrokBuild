# TitleScreen.gd
extends Control

const STORY_SCENE := "res://Scene/UI/StoryScreen.tscn"

@onready var play_button: Button = $Center/VBox/ButtonPlay
@onready var quit_button: Button = $Center/VBox/ButtonQuit

func _ready() -> void:
	_apply_ui_font()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(STORY_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _apply_ui_font() -> void:
	# 預設字型不一定含中文，改走系統字型
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft JhengHei", "Microsoft YaHei", "Noto Sans CJK TC"])
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	theme = ui_theme
