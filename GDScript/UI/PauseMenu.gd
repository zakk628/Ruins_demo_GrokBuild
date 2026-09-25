# PauseMenu.gd
extends Control

@onready var resume_button = $HBoxContainer/VBoxContainer/Button_Resume
@onready var quit_button = $HBoxContainer/VBoxContainer/Button_Quit

func _ready():
	# 初始狀態：隱藏選單
	visible = false
	# 連接按鈕訊號
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("ESC"):
		toggle_pause()

func toggle_pause():
	visible = !visible
	if visible:
		# 顯示滑鼠游標
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Engine.time_scale = 0   # 暫停遊戲
	else:
		# 隱藏滑鼠游標
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Engine.time_scale = 1   # 恢復遊戲

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()
