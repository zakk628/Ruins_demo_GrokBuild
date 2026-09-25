# AttackController.gd
extends Node

@export var attack_damage := 20          # 每次攻擊傷害值

# 記錄當前攻擊是否正在進行（防止重複扣血）
var is_attacking := false

func _ready():
	# 連接左右 HitBox 的訊號
	$"../../Character/Human_proto_01/Prototype_Rig/Skeleton3D/weapon_L/Hitbox_L".area_entered.connect(_on_hitbox_entered)
	$"../../Character/Human_proto_01/Prototype_Rig/Skeleton3D/weapon_R/Hitbox_R".area_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(area: Area3D):
	print("HitBox 偵測到碰撞！對方群組: ", area.get_groups())  # 新增這行
	if is_attacking:
		return
	
	# 檢查對方是否有 HurtBox（木樁的傷害接收區）
	if area.is_in_group("HurtBox"):
		is_attacking = true
		
		# 正確找到 HealthController
		var health_controller = area.get_parent().get_node_or_null("Controller/HealthController")
		
		if health_controller :
			if health_controller.has_method("take_damage"):
				health_controller.take_damage(attack_damage)
				print("成功對木樁造成 ", attack_damage, " 傷害！")
			else:
				print("錯誤：找不到 take_damage 函數")
		else:
			print("錯誤：找不到 HealthController")
		
		# 防止連續扣血
		await get_tree().create_timer(0.2).timeout
		is_attacking = false
		
		
