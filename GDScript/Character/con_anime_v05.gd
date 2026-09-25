# con_anime.gd - 動畫控制腳本
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

func set_attack(attacking: bool):
	"""切換是否進入 fight_state"""
	anim_tree.set("parameters/conditions/is_attack", attacking)
	anim_tree.set("parameters/conditions/!is_attack", !attacking)
	
	# 只有在「沒有正在連擊」且「剛開始按下」時才啟動
	if attacking and not is_in_combo:
		is_in_combo = true
		combo_step = 1
		_start_combo_sequence()

func _start_combo_sequence():
	if combo_step == 1:
		anim_tree.set("parameters/fight_state/conditions/com_01", true)
		trigger_combo1()
		print("計數1，combo1")
		await get_tree().create_timer(0.35).timeout
		combo_step = 2
		_start_combo_sequence()
		
	elif combo_step == 2:
		anim_tree.set("parameters/fight_state/conditions/com_02", true)
		trigger_combo2()
		print("計數2，combo2")
		await get_tree().create_timer(0.35).timeout
		combo_step = 3
		_start_combo_sequence()
		
	elif combo_step == 3:
		anim_tree.set("parameters/fight_state/conditions/com_03", true)
		trigger_combo3()
		print("計數3，combo3")
		await get_tree().create_timer(0.35).timeout
		combo_step = 4
		_start_combo_sequence()
		
	elif combo_step == 4:
		anim_tree.set("parameters/fight_state/conditions/fight_idle", true)
		fight_idle()
		print("計數4，idle")
		await get_tree().create_timer(1.0).timeout
		
		# ==== 加強版完全重置 ====
		combo_step = 0
		is_in_combo = false
		
		# 強制重置所有狀態
		anim_tree.set("parameters/conditions/is_attack", false)
		anim_tree.set("parameters/conditions/!is_attack", true)
		anim_tree.set("parameters/fight_state/conditions/com_01", false)
		anim_tree.set("parameters/fight_state/conditions/com_02", false)
		anim_tree.set("parameters/fight_state/conditions/com_03", false)
		anim_tree.set("parameters/fight_state/conditions/fight_idle", false)
		
		print("三連擊完全結束，已重置")
		
func trigger_combo1():
	"""正確觸發 Combo_1st"""
	anim_tree.set("parameters/fight_state/Combo_01/type_slash/blend_position",1.0)
	anim_tree.set("parameters/fight_state/Combo_01/TimeScale/scale", 4.0)
	
func trigger_combo2():
	"""正確觸發 Combo_2nd"""
	anim_tree.set("parameters/fight_state/Combo_02/type_stab/blend_position", 1.0)
	anim_tree.set("parameters/fight_state/Combo_02/TimeScale/scale", 4.0)
	
func trigger_combo3():
	"""正確觸發 Combo_3rd"""
	anim_tree.set("parameters/fight_state/Combo_03/type_stomp/blend_position", 1.0)
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
