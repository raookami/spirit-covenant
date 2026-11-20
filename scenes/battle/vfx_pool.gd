class_name VFXPool
extends Node2D

var projectile_pool: Array = []
var damage_pool: Array = []


func spawn_projectile(from_pos: Vector2, target_pos: Vector2, proj_color: Color):
	var proj: ColorRect
	if projectile_pool.size() > 0:
		proj = projectile_pool.pop_back()
	else:
		proj = ColorRect.new()
		proj.size = Vector2(8, 8)
		proj.z_index = 5
		add_child(proj)

	proj.color = proj_color
	proj.position = from_pos - Vector2(4, 4)
	proj.visible = true

	var tween := get_tree().create_tween()
	tween.tween_property(proj, "position", target_pos - Vector2(4, 4), 0.16)
	tween.tween_callback(_recycle_projectile.bind(proj))


func _recycle_projectile(proj: ColorRect):
	if not is_instance_valid(proj):
		return
	proj.visible = false
	if not projectile_pool.has(proj):
		projectile_pool.append(proj)


func spawn_damage_number(pos: Vector2, amount: int, elem_color: Color = Color.WHITE):
	var lbl: Label
	if damage_pool.size() > 0:
		lbl = damage_pool.pop_back()
	else:
		lbl = Label.new()
		lbl.z_index = 15
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		lbl.add_theme_constant_override("outline_size", 3)
		add_child(lbl)

	lbl.text = str(amount)
	lbl.add_theme_color_override("font_color", elem_color)
	lbl.modulate = Color(1, 1, 1, 1)
	var jitter_x := randf_range(-14.0, 14.0)
	lbl.position = pos + Vector2(jitter_x - 12.0, -10.0)
	lbl.visible = true

	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(
		lbl, "position:y", lbl.position.y - 28.0, 0.45
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.45).set_delay(0.15)
	tween.chain().tween_callback(_recycle_damage_number.bind(lbl))


func _recycle_damage_number(lbl: Label):
	if not is_instance_valid(lbl):
		return
	lbl.visible = false
	if not damage_pool.has(lbl):
		damage_pool.append(lbl)