# StoryScreen.gd
extends Control

# 測試場實際檔名是 world.tscn，不是 World.tscn
const WORLD_SCENE := "res://Scene/world.tscn"
const AUTO_ENTER_SECONDS := 15.0

var _has_entered := false

@onready var continue_button: Button = $ButtonContinue
@onready var auto_enter: Timer = $AutoEnter

func _ready() -> void:
	_apply_ui_font()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	continue_button.pressed.connect(_enter_world)
	auto_enter.wait_time = AUTO_ENTER_SECONDS
	auto_enter.one_shot = true
	auto_enter.timeout.connect(_enter_world)
	auto_enter.start()

func _enter_world() -> void:
	# 按鈕與 15 秒倒數可能同時觸發，只換場一次
	if _has_entered:
		return
	_has_entered = true
	auto_enter.stop()
	continue_button.disabled = true
	get_tree().change_scene_to_file(WORLD_SCENE)

func _apply_ui_font() -> void:
	# 預設字型不一定含中文，改走系統字型
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft JhengHei", "Microsoft YaHei", "Noto Sans CJK TC"])
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	theme = ui_theme
