class_name VFXPool
extends Node2D

var projectile_pool: Array = []


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