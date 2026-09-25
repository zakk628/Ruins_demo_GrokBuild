# Character.gd - 主角色控制腳本
extends CharacterBody3D
class_name Character_v05_root_motion

@export var move_speed := 5.0
@export var sprint_speed := 9.0
@export var walk_speed := 1.0

var is_sprinting := false
var is_walking := false
var is_locked := false

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var camera_controller = $Controller/CameraController
@onready var CharacterModel = $Character
@onready var anime = $Controller/AnimeController   # ← 新增這一行

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	handle_input(delta)
	move_and_slide()

func handle_input(delta):
	# ———————————————  按鍵輸入 ——————————————— 
	# ═══════════════ 攻擊判斷 ═══════════════
	var is_attack = Input.is_action_pressed("attack") # LMB 或 RMB
	action_attack(is_attack)                          # 由action_attack()通知動畫撥放狀態
	# ═══════════════ 迴避判斷 ═══════════════
	var is_avoid = Input.is_action_pressed("avoid")   # Space
	action_avoid(is_avoid)                            # 由action_avoid()通知動畫撥放狀態
	# ═══════════════ 中斷移動 ═══════════════
	if is_avoid or is_attack:
		velocity.x = move_toward(velocity.x, 0, move_speed * 25 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 25 * delta)
	# ═══════════════ 鎖定切換 ═══════════════
	if Input.is_action_just_pressed("lock"):          # MMB
		is_locked = !is_locked                        # 切換核心
		anime.set_locked(is_locked)                   # 通知動畫切換撥放狀態
		print("鎖定狀態切換 → ", is_locked)             # debug
	# ═══════════════ 階層設定 ══════════════
	var is_action_active = is_attack or is_avoid      # is_action_active 狀態不會移動
	if not is_action_active:
	# ———————————————  一般移動 ———————————————  （未鎖定）
		if not is_locked:
			# ═══════════════ 一般移動 ═══════════════
			# === 移動輸入 ===
			var input_dir = Input.get_vector( "move_left","move_right","move_backward","move_forward")
			is_sprinting = Input.is_action_pressed("sprint") # Shift
			is_walking = Input.is_action_pressed("slow")     # Alt
			# === 移動數值 === blend_value
			var blend_value = -1.0                           # 預設       → -1
			if input_dir != Vector2.ZERO:
				if is_sprinting: blend_value =  1.0          # WASD+Shift → 1
				elif is_walking: blend_value = -0.5          # WASD+Alt   → -0.5
				else:            blend_value =  0.0          # WASD       → 0
			# === 更新動畫 === blend_value
			anime.update_normal_state(blend_value) # 傳送數值
			
			# ═══════════════ 移動速度 ═══════════════
			var current_speed = move_speed
			if is_sprinting:
				current_speed = sprint_speed
			elif is_walking:
				current_speed = walk_speed
				
			# ═══════════════ 前方設定 ═══════════════ 
			var cam_y = camera_controller.cam_y if camera_controller else null
			if cam_y and input_dir != Vector2.ZERO:
				# ☰☰☰☰☰ 前後設定 ☰☰☰☰☰ Character/Camera
				var forward = cam_y.global_transform.basis.z
				forward.y = 0
				forward = forward.normalized()
				# ☰☰☰☰☰ 左右設定 ☰☰☰☰☰ Character/Camera
				var right = -cam_y.global_transform.basis.x
				right.y = 0
				right = right.normalized()
				# ☰☰☰☰☰ 方向判斷 ☰☰☰☰☰ Character
				var move_dir = forward * input_dir.y + right * input_dir.x
				move_dir = move_dir.normalized()
				# ☰☰☰☰☰ 速度設定 ☰☰☰☰☰ Character ﹝實際引發一般移動﹞
				velocity.x = move_dir.x * current_speed * delta * 60
				velocity.z = move_dir.z * current_speed * delta * 60
				# ☰☰☰☰☰ 模型面向 ☰☰☰☰☰ Model
				if move_dir != Vector3.ZERO and CharacterModel:
					CharacterModel.look_at(CharacterModel.global_position + -move_dir, Vector3.UP)
			else:
				# ☰☰☰☰☰ 靜止狀態 ☰☰☰☰☰
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
		
		# ———————————————  戰鬥移動 ———————————————  （鎖定）
		else:
			# ═══════════════ 戰鬥移動 ═══════════════
			# === 移動輸入 === 
			var input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
			# === 移動變數 ===
			var forward = 0.0   # 前後移動變數
			var strafe = 0.0    # 橫向移動變數
			# === 輸入變數 === forward, strafe
			if Input.is_action_pressed("move_forward"):   forward =  1.0
			elif Input.is_action_pressed("move_backward"):forward = -1.0
			if Input.is_action_pressed("move_left"):      strafe =  -1.0
			elif Input.is_action_pressed("move_right"):   strafe =   1.0
			# === 更新動畫 === forward, strafe
			anime.update_battle_move(forward, strafe)
			
			# ═══════════════ 移動速度 ═══════════════ 切換
			# === 模式輸入 === 
			var is_battle_sprint = Input.is_action_pressed("sprint")  # 按鍵輸入直接判斷為true
			var is_battle_walk = Input.is_action_pressed("slow")
			var battle_mode = "run"  # 預設 run
			# === 模式切換 ===
			if is_battle_sprint:
				battle_mode = "sprint"
			elif is_battle_walk:
				battle_mode = "walk"
			# === 更新動畫 === battle_mode/is_battle_sprint
			anime.update_battle_speed(battle_mode)
			anime.update_battle_sprint(is_battle_sprint)
			
			# ═══════════════ 移動速度 ═══════════════ 設定
			var current_speed = move_speed    
			if battle_mode == "sprint":
				current_speed = sprint_speed * 1.5
			elif battle_mode == "walk":
				current_speed = move_speed * 0.2 
			
			# ═══════════════ 鏡頭轉向 ═══════════════ 
			var cam_y = camera_controller.cam_y if camera_controller else null
			if cam_y and input_dir != Vector2.ZERO:
				var move_dir = Vector3.ZERO
				# ═════ 衝刺戰鬥狀態 ═════
				if is_battle_sprint:
					# ☰☰☰☰☰ 前後設定 ☰☰☰☰☰ Character/Camera
					var forward_dir = cam_y.global_transform.basis.z
					forward_dir.y = 0
					forward_dir = forward_dir.normalized()
					# ☰☰☰☰☰ 左右設定 ☰☰☰☰☰ Character/Camera
					var right_dir = -cam_y.global_transform.basis.x
					right_dir.y = 0
					right_dir = right_dir.normalized()
					# ☰☰☰☰☰ 方向判斷 ☰☰☰☰☰ Character
					move_dir = forward_dir * input_dir.y + right_dir * input_dir.x
					move_dir = move_dir.normalized()
					# ☰☰☰☰☰ 模型面向 ☰☰☰☰☰ Model
					if move_dir != Vector3.ZERO and CharacterModel:
						CharacterModel.look_at(CharacterModel.global_position + -move_dir, Vector3.UP)

				# ═════ 一般戰鬥狀態 ═════
				else:
					# ☰☰☰☰☰ 前方設定 ☰☰☰☰☰ Character/Camera
					var lock_forward = cam_y.global_transform.basis.z
					lock_forward.y = 0
					lock_forward = lock_forward.normalized()
					# ☰☰☰☰☰ 方向判斷 ☰☰☰☰☰ Character/移動方向仍然以鏡頭為基準
					move_dir = lock_forward * input_dir.y + (-cam_y.global_transform.basis.x.normalized()) * input_dir.x
					move_dir = move_dir.normalized()
					# ☰☰☰☰☰ 模型面向 ☰☰☰☰☰ Model
					if lock_forward != Vector3.ZERO and CharacterModel:
						CharacterModel.look_at(CharacterModel.global_position + -lock_forward, Vector3.UP)
						
				# ☰☰☰☰☰ 速度設定 ☰☰☰☰☰ Character ﹝實際引發戰鬥移動﹞
				velocity.x = move_dir.x * current_speed * delta * 60
				velocity.z = move_dir.z * current_speed * delta * 60
			else:
				# ☰☰☰☰☰ 速度設定 ☰☰☰☰☰ Character ﹝逐漸停止戰鬥移動﹞
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
	else:pass
	# ———————————————  Root Motion ———————————————  動畫位移轉換為真實位移（只在攻擊時使用）
	# === Animation Mix 的Track選項選擇IK_main ===
	# === Animation Mix 的Local選項勾選 ===
	if anim_tree:
		var root_motion = anim_tree.get_root_motion_position()   # 取得這一幀的位移
		if root_motion != Vector3.ZERO:
			# 把 Root Motion 的位移轉換成世界方向後移動
			var world_motion = CharacterModel.global_transform.basis * root_motion
			velocity.x += world_motion.x * 30
			velocity.z += world_motion.z * 30
			
func action_attack(is_attack:bool):
	anime.set_attack(is_attack) # 通知動畫撥放攻擊動畫
	
func action_avoid(is_avoid:bool):
	anime.set_avoid(is_avoid)   # 通知動畫撥放迴避動畫
