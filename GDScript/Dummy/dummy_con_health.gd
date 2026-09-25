# HealthController.gd
extends Node

@export var max_health := 100
var current_health := max_health

# 按照你的結構調整路徑
@onready var progress_bar = $"../../HealthBar/SubViewportContainer/SubViewport/ProgressBar"
@onready var sub_viewport = $"../../HealthBar/SubViewportContainer/SubViewport"
@onready var sprite = $"../../HealthBar"   # Sprite3D

func _ready():
	current_health = max_health
	update_health_bar()
	print("HealthController 初始化完成，路徑正確：", progress_bar != null)

func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health_bar()
	
	print("木樁受到 ", amount, " 傷害！剩餘: ", current_health)
	
	if current_health <= 0:
		print("木樁已死亡！正在重生...")
		await get_tree().create_timer(1.0).timeout
		reset_health()

func update_health_bar():
	if progress_bar:
		progress_bar.max_value = max_health
		progress_bar.value = current_health
		
		# 強制刷新
		if sub_viewport:
			sub_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
			await get_tree().process_frame
			sub_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
		
		# 強制刷新 Sprite3D
		if sprite:
			sprite.texture = null
			await get_tree().process_frame
			sprite.texture = sub_viewport.get_texture()
		
		print("血條已更新為 ", current_health, "%")
	else:
		print("錯誤：找不到 ProgressBar，請檢查路徑")

func reset_health():
	current_health = max_health
	update_health_bar()
	print("血量已重置為 100%")
