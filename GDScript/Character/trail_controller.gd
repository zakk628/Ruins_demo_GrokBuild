# trail_controller.gd - 武器平面揮擊軌跡
extends Node

## 顯示後拉長到完整寬度的時間（秒）
@export var show_time: float = 0.14
## 拉長完成後淡出的時間（秒）
@export var fade_time: float = 0.18
## 軌跡靠刀身、拉長時保持不動的本地 X
@export var anchor_x: float = 0.5
## 開始時的寬度比例
@export var start_stretch: float = 0.08

var _trail: MeshInstance3D
var _material: StandardMaterial3D
var _base_albedo: Color = Color(0.78, 0.93, 1, 0.62)
var _rest_position: Vector3
var _rest_scale: Vector3 = Vector3.ONE
var _full_width: float = 1.0
var _tween: Tween

func _ready() -> void:
	_trail = get_parent() as MeshInstance3D
	if _trail == null:
		push_warning("TrailController 必須放在 Trail MeshInstance3D 底下")
		return

	_rest_position = _trail.position
	_rest_scale = _trail.scale
	_full_width = _read_width()
	_setup_material()
	_hide_trail()

func start_trail() -> void:
	if _trail == null:
		return

	if _tween != null and _tween.is_valid():
		_tween.kill()

	var stretch_from := clampf(start_stretch, 0.0, 1.0)
	_trail.visible = true
	_apply_stretch(stretch_from)
	_set_alpha(_base_albedo.a)

	_tween = create_tween()
	_tween.tween_method(_apply_stretch, stretch_from, 1.0, maxf(show_time, 0.0))
	_tween.tween_method(_set_alpha, _base_albedo.a, 0.0, maxf(fade_time, 0.0))
	_tween.tween_callback(_hide_trail)

func _read_width() -> float:
	var mesh := _trail.mesh
	if mesh is QuadMesh:
		return (mesh as QuadMesh).size.x * absf(_rest_scale.x)
	return absf(_rest_scale.x)

func _apply_stretch(amount: float) -> void:
	# 沿本地 X 拉長，內側停在 anchor_x，避免從面片中心往兩側撐開。
	var stretch := clampf(amount, 0.0, 1.0)
	_trail.scale = Vector3(_rest_scale.x * maxf(stretch, 0.001), _rest_scale.y, _rest_scale.z)
	var width := _full_width * stretch
	_trail.position = Vector3(anchor_x + width * 0.5, _rest_position.y, _rest_position.z)

func _setup_material() -> void:
	var source := _trail.get_active_material(0)
	if source is StandardMaterial3D:
		_material = (source as StandardMaterial3D).duplicate() as StandardMaterial3D
	else:
		_material = StandardMaterial3D.new()
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_material.albedo_color = _base_albedo

	_trail.material_override = _material
	_base_albedo = _material.albedo_color

func _set_alpha(alpha: float) -> void:
	if _material == null:
		return
	var color := _base_albedo
	color.a = alpha
	_material.albedo_color = color

func _hide_trail() -> void:
	if _trail == null:
		return
	_trail.visible = false
	_apply_stretch(1.0)
	_set_alpha(_base_albedo.a)
