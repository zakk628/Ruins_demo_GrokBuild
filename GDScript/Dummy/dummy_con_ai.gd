extends Node

# ==================== 節點路徑 ====================
@onready var dummy_base: CharacterBody3D = get_parent().get_parent()
@onready var animation_player: AnimationPlayer = dummy_base.get_node("Dummy_Proto/AnimationPlayer")
@onready var animation_tree: AnimationTree = dummy_base.get_node("AnimationTree")  # 預留，之後可切換使用
# ==================== 參測目標 ====================
@export var player_path: NodePath = "../..Player"  # 可在 Inspector 手動指定玩家
var player: Node3D
# ==================== 狀態設定 ====================
enum State { IDLE, CHASE, ATTACK, STUN, DEATH }
var current_state = State.IDLE
# ==================== 相關參數 ====================
var attack_range = 3.5
var move_speed = 4.0
var attack_cooldown = 2.0
var last_attack_time = 0.0

func _ready():
	# ———————————————  輸入目標 ——————————————— 
	if player_path:
		player = get_node_or_null(player_path)
	# ———————————————  群組目標 ——————————————— 
	if player == null:
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if current_state == State.DEATH or player == null:
		return
	
	match current_state:
		State.IDLE:
			idle_behavior()
		
		State.CHASE:
			chase_behavior(delta)
		
		State.ATTACK:
			attack_behavior()
		
		State.STUN:
			pass  # 等待動畫結束，由外部或信號切換

# ==================== 行為 ====================

func idle_behavior():
	animation_player.play("A00_move_idle")
	current_state = State.CHASE  # 自動進入追擊

func chase_behavior(delta):
	var direction = (player.global_position - dummy_base.global_position).normalized()
	
	# 移動
	dummy_base.velocity = direction * move_speed
	dummy_base.move_and_slide()
	
	# 面向玩家（簡單版）
	dummy_base.look_at(dummy_base.global_position - direction, Vector3.UP)
	
	# 距離判斷攻擊
	var distance = dummy_base.global_position.distance_to(player.global_position)
	
	if distance < attack_range and Time.get_ticks_msec() - last_attack_time > attack_cooldown * 1000:
		current_state = State.ATTACK

func attack_behavior():
	animation_player.play("C02_atk_weapon_stab")
	last_attack_time = Time.get_ticks_msec()
	
	# 等待攻擊結束後返回追擊
	await get_tree().create_timer(1.8).timeout
	if current_state != State.DEATH:
		current_state = State.CHASE

# ==================== 外部呼叫 ====================

func take_damage(amount: int = 10):
	if current_state == State.DEATH:
		return
	current_state = State.STUN
	animation_player.play("B04_ract_stun_down")
	
	await get_tree().create_timer(1.5).timeout
	if current_state != State.DEATH:
		current_state = State.CHASE

func die():
	current_state = State.DEATH
	animation_player.play("D04_spec_dummy_attack")  # 暫用，可之後換死亡動畫
