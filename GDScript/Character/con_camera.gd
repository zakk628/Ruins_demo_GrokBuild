# Con_Camera.gd - 鏡頭控制腳本
extends Node

# ====== Camera node ====== 
@onready var cam = $"../../Cam"
@onready var cam_y = $"../../Cam/Cam_y"
@onready var cam_z = $"../../Cam/Cam_y/Cam_z"
@onready var camera = $"../../Cam/Cam_y/Cam_z/Camera3D"
#  ====== Camera control ====== 
@export var sensitivity := 0.05
@export var distance := 50.0       # 鏡頭與角色間的距離/原本Cam_z的Position設定都歸0
@export var height := 2            # 鏡頭與角色間的高度/原本Cam_y的Position設定都歸0
#  ====== Camera pan ====== 
@export var min_pitch :=  0.0      # 鏡頭垂直最小仰視角（向上看）
@export var max_pitch := 12.5      # 鏡頭垂直最大俯視角（向下看）
#  ====== Camera variable ====== 
var yaw := 0.0             # 鏡頭水平初始角度(預設看到角色背部)
var pitch := 0.0           # 鏡頭垂直初始角度(預設看到角色背部) → Camera pan

# ——————————————— 初始設定 ———————————————
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # 鏡頭捕捉/隱藏滑鼠
	cam_z.position.z = -distance                     # 透過Cam_z調整鏡頭與角色間的距離

# ——————————————— 滑鼠旋轉 ——————————————— 
func _input(event):
	# 如果暫停中，就不處理滑鼠旋轉
	if Engine.time_scale == 0.0:
		return
		
	if event is InputEventMouseMotion:
		# 鏡頭/滑鼠旋轉靈敏度
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		# 鏡頭/滑鼠旋轉靈敏度限制
		pitch = clamp(pitch, min_pitch, max_pitch)
		# 鏡頭/滑鼠旋轉
		cam_y.rotation_degrees.y = yaw
		cam_z.rotation_degrees.x = pitch

# ——————————————— 鏡頭位置 ——————————————— 
func _process(delta):
	# 如果暫停中，就不處理鏡頭位置
	if Engine.time_scale == 0.0:
		return
		
	# 抓取根節點：get_parent()為Controller；get_parent().get_parent()為human
	var character = get_parent().get_parent()
	# 調整鏡頭位置
	if character and character is CharacterBody3D:
		# 透過height調整cam_y的高度(使用Vector3的lerp)
		cam_y.global_position = cam_y.global_position.lerp(character.global_position + Vector3(0, height, 0), 12 * delta)
		# 透過distance調整cam_z的距離(使用全域的lerp)
		cam_z.position.z = lerp(cam_z.position.z, -distance, 8 * delta)
		# ===================== lerp說明 =====================
		# 線性插值 Linear Interpolation
		# 基本數值 (目前數值, 目標數值, 過渡速度)
		# 使用Vector3的lerp，可以省略"目前數值"
		# 使用全域的lerp，必須載明三個數職
