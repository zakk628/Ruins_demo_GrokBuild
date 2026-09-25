# LockMark.gd
extends Node3D

@export var lock_color: Color = Color(0, 1, 1, 1.0)      # 青色，完全不透明
@export var test_color: Color = Color(1, 0.3, 0, 1.0)    # 橙色，用於測試

@onready var mesh = $Lock_Mesh

func _ready():
	# 測試階段：預設一直顯示且顯眼
	visible = true
	show_lock()

func show_lock():
	visible = true
	if mesh and mesh.material_override:
		mesh.material_override.albedo_color = lock_color
		mesh.material_override.emission_enabled = true
		mesh.material_override.emission = lock_color * 3.0   # 加強發光效果

func hide_lock():
	visible = false
	if mesh and mesh.material_override:
		mesh.material_override.albedo_color = test_color
		mesh.material_override.emission_enabled = false
