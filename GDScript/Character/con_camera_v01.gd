# Con_Camera.gd - 鏡頭控制腳本
extends Node

@export var sensitivity := 0.05
@export var distance := 6.0
@export var height := 0.0

@onready var cam = $"../../Cam"
@onready var cam_y = $"../../Cam/Cam_y"
@onready var cam_z = $"../../Cam/Cam_y/Cam_z"
@onready var camera = $"../../Cam/Cam_y/Cam_z/Camera3D"

var yaw := -90.0
var pitch := -20.0
var is_paused := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	# 如果暫停中，就不處理滑鼠轉動
	if Engine.time_scale == 0.0:
		return
	
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -80, 40)
		
		cam_y.rotation_degrees.y = yaw
		cam_z.rotation_degrees.x = pitch

func _process(delta):
	# 取得 human 角色位置（Controller → human）
	var character = get_parent().get_parent()
	if character and character is CharacterBody3D:
		# 讓 Cam 跟隨角色位置
		cam.global_position = cam.global_position.lerp(character.global_position + Vector3(0, height, 0), 12 * delta)
			
