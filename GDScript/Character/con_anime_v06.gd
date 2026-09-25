# con_anime.gd - 動畫控制腳本_傷害區隔
extends Node

@onready var anim_tree: AnimationTree = $"../../AnimationTree"

func _ready():
	if anim_tree:
		anim_tree.active = true

# ——————————————— normal_state ———————————————
func update_normal_state(blend_value: float):
	#print("正在更新 normal_state, speed =", blend_value) #debug
	anim_tree.set("parameters/normal_state/BlendSpace1D/blend_position", blend_value)
	# 根據 blend_value 設定不同動畫的速度
	if blend_value >= 0.5:           # 衝刺
		anim_tree.set("parameters/normal_state/TimeScale/scale", 3.0)
		#print("觸發sprint") #debug
	elif blend_value >= -0.25:         # 跑步
		anim_tree.set("parameters/normal_state/TimeScale/scale", 2.0)
		#print("觸發run") #debug
	elif blend_value >= -0.75:        # 走路
		anim_tree.set("parameters/normal_state/TimeScale/scale", 1.0)
		#print("觸發walk") #debug
	else:                            # 待命
		anim_tree.set("parameters/normal_state/TimeScale/scale", 0.8)
		
# ——————————————— locked切換 ———————————————
func set_locked(locked: bool):
	"""切換鎖定狀態"""
	anim_tree.set("parameters/conditions/is_locked", locked)
	anim_tree.set("parameters/conditions/!is_locked", !locked)
	
# ——————————————— battle_state ——————————————— locked
func update_battle_move(forward: float, strafe: float):
	"""更新 battle_move (BlendSpace2D)"""
	anim_tree.set("parameters/battlel_state/BlendSpace2D/blend_position", Vector2(strafe, forward))

# ——————————————— battle_state ——————————————— locked+sprint
func update_battle_sprint(active: bool):
	"""戰鬥衝刺 - 完全取代"""
	if active:
		anim_tree.set("parameters/battlel_state/Blend2/blend_amount", 1.0)   # 完全顯示衝刺
	else:
		anim_tree.set("parameters/battlel_state/Blend2/blend_amount", 0.0)   # 回到一般移動
		
# ——————————————— battle_state ——————————————— speed
func update_battle_speed(mode: String):
	"""mode 可以是 "walk", "run", "sprint" """
	if mode == "sprint":
		anim_tree.set("parameters/battlel_state/TimeScale/scale", 2.5)
	elif mode == "run":
		anim_tree.set("parameters/battlel_state/TimeScale/scale", 2.0)
	elif mode == "walk":
		anim_tree.set("parameters/battlel_state/TimeScale/scale", 1.0)
	else:
		anim_tree.set("parameters/battlel_state/TimeScale/scale", 1.0)

# ——————————————— fight_state ———————————————
var is_in_combo := false
var combo_step := 0

# === 可在Inspector調整的參數 ===
@export var combo_times: Array[float] = [0.35, 0.35, 0.4, 0.35]  # 各階段等待時間
@export var combo_blend_values: Array[float] = [1.0, 1.0, 1.0]   # 各招式的 blend_position

func set_attack(attacking: bool):
	"""切換是否進入 fight_state"""
	anim_tree.set("parameters/conditions/is_attack", attacking)
	anim_tree.set("parameters/conditions/!is_attack", !attacking)
	
	# 通知 DamageController 是否正在攻擊
	var damage_controller = get_parent().get_node_or_null("DamageController")  # 或你實際的節點名稱
	if damage_controller:
		damage_controller.is_attacking = attacking
		#print("攻擊狀態切換 → ", attacking)   # debug
	else:
		print("警告：找不到 DamageController")
	
	if attacking and not is_in_combo:
		is_in_combo = true
		combo_step = 1
		_start_combo_sequence()

func _start_combo_sequence():
	if combo_step > 3:
		# 結束後回到 idle
		fight_idle()
		is_in_combo = false
		combo_step = 0
		
		# 三連擊全部結束，關閉傷害
		#var damage_controller = get_parent().get_node_or_null("DamageController")
		#if damage_controller:
			#damage_controller.is_attacking = false
			
		anim_tree.set("parameters/conditions/is_attack", false)
		anim_tree.set("parameters/conditions/!is_attack", true)
		anim_tree.set("parameters/fight_state/conditions/com_01", false)
		anim_tree.set("parameters/fight_state/conditions/com_02", false)
		anim_tree.set("parameters/fight_state/conditions/com_03", false)
		print("三連擊結束，已回到待命")
		return
	
	# 統一觸發當前步驟
	trigger_combo(combo_step)
	print("計數", combo_step, "，combo", combo_step)
	
	# 等待後推進下一步
	await get_tree().create_timer(combo_times[combo_step-1]).timeout
	
	# 【重點】：動畫結束後才開啟傷害
	#var damage_controller = get_parent().get_node_or_null("DamageController")
	#if damage_controller:
		#damage_controller.is_attacking = true
		#print("第", combo_step, "招動畫結束 → 開啟傷害判定")
		
	combo_step += 1
	_start_combo_sequence()

# 統一的觸發函數（取代原本的三個重複函數）
func trigger_combo(step: int):
	var blend_value = combo_blend_values[step-1]
	
	if step == 1:
		anim_tree.set("parameters/fight_state/conditions/com_01", true)
		anim_tree.set("parameters/fight_state/Combo_01/type_slash/blend_position", blend_value)
		anim_tree.set("parameters/fight_state/Combo_01/TimeScale/scale", 4.0)
		
	elif step == 2:
		anim_tree.set("parameters/fight_state/conditions/com_02", true)
		anim_tree.set("parameters/fight_state/Combo_02/type_stab/blend_position", blend_value)
		anim_tree.set("parameters/fight_state/Combo_02/TimeScale/scale", 4.0)
		
	elif step == 3:
		anim_tree.set("parameters/fight_state/conditions/com_03", true)
		anim_tree.set("parameters/fight_state/Combo_03/type_stomp/blend_position", blend_value)
		anim_tree.set("parameters/fight_state/Combo_03/TimeScale/scale", 4.0)

func fight_idle():
	anim_tree.set("parameters/fight_state/fight_idle/fight_idle/blend_position", 0.0)
	anim_tree.set("parameters/fight_state/fight_idle/TimeScale/scale", 2.0)
	
# ——————————————— avoid_state ———————————————
func set_avoid(avoiding: bool):
	"""切換是否進入 avoid_state"""
	anim_tree.set("parameters/conditions/is_avoid", avoiding)
	anim_tree.set("parameters/conditions/!is_avoid", !avoiding)
	
	if avoiding:
		anim_tree.set("parameters/avoid_state/TimeScale/scale", 1.5)
