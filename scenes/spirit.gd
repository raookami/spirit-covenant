extends Node2D

# ============================================================
# SIGNALS
# ============================================================
signal spirit_died

# ============================================================
# CONSTANTS
# ============================================================
const BAR_WIDTH := 58.0
const BAR_Y_HP := 58.0
const BAR_Y_SKILL := 65.0
const BLOCK_RADIUS_TILES := 0.6
const FACING_FLIP_CORRECTION := true

# ============================================================
# VARIABLES (PUBLIC)
# ============================================================
var spirit_id: String = ""
var unit_type: String = "melee"
var hp: int = 500
var max_hp: int = 500
var atk: int = 1
var phys_def: int = 0
var magic_def: int = 0

var attack_patterns: Dictionary = {}
var facing_dir: Vector2i = Vector2i(0, -1)

var attack_cd: float = 1.5
var block_count: int = 1
var tile_size: int = 128

var battle_ref: Node
var attack_timer: float = 0.0
var blocking: Array = []

var anim_sprite: AnimatedSprite2D
var live2d_model: Node2D
var range_circle: Node2D
var is_live2d: bool = false
var base_facing_scale_x: float = 1.0

var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect
var skill_bar_bg: ColorRect
var skill_bar_fill: ColorRect

# ============================================================
# VARIABLES (PRIVATE) — Wajib di paling bawah
# ============================================================
var _range_visible: bool = false


# ============================================================
# FUNCTIONS
# ============================================================
func _ready():
	_build_range_indicator()


func _process(delta):
	if battle_ref == null:
		return

	if unit_type == "melee":
		_process_melee(delta)
	else:
		_process_ranged(delta)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos := get_global_mouse_position()
		if position.distance_to(mouse_pos) < tile_size * 0.5:
			_range_visible = not _range_visible
			range_circle.visible = _range_visible


func init(battle: Node, data: Dictionary):
	battle_ref = battle
	spirit_id = data.get("id", "")
	unit_type = data.get("unit_type", "melee")
	hp = data.get("hp", 500)
	max_hp = hp
	atk = data.get("atk", 1)
	phys_def = data.get("phys_def", 0)
	magic_def = data.get("magic_def", 0)
	attack_patterns = data.get("attack_patterns", {"up": [Vector2i(0, -1)]})
	attack_cd = data.get("atk_spd", 1.5)
	block_count = data.get("block", 1)
	_build_visuals()
	_build_hp_bar()


func set_facing(dir: Vector2i):
	facing_dir = dir
	_apply_facing_visual()
	if range_circle:
		_refresh_range_indicator()


func _get_rotated_pattern() -> Array:
	var key := "up"
	if facing_dir == Vector2i(0, -1):
		key = "up"
	elif facing_dir == Vector2i(1, 0):
		key = "right"
	elif facing_dir == Vector2i(0, 1):
		key = "down"
	elif facing_dir == Vector2i(-1, 0):
		key = "left"

	return attack_patterns.get(key, attack_patterns.get("up", []))


func _apply_facing_visual():
	pass


func _build_visuals():
	var model_path = (
		"res://assets/spirites/characters/%s/%s_idle.model3.json" % [spirit_id, spirit_id]
	)
	if ResourceLoader.exists(model_path):
		_build_live2d_visual(model_path)
		return

	anim_sprite = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 12)

	var loaded_any := false
	for i in range(24):
		var path = (
			"res://assets/spirites/characters/%s/%s_idle_%04d.png" % [spirit_id, spirit_id, i]
		)
		if ResourceLoader.exists(path):
			frames.add_frame("idle", load(path))
			loaded_any = true

	if not loaded_any:
		var placeholder = ColorRect.new()
		placeholder.size = Vector2(48, 48)
		placeholder.position = Vector2(-24, -36)
		placeholder.color = Color(0.8, 0.5, 0.1) if unit_type == "melee" else Color(0.2, 0.5, 0.9)
		add_child(placeholder)
	else:
		anim_sprite.sprite_frames = frames
		anim_sprite.scale = Vector2(0.6, 0.6)
		anim_sprite.z_index = 1
		anim_sprite.play("idle")
		add_child(anim_sprite)
		base_facing_scale_x = anim_sprite.scale.x


func _build_hp_bar():
	hp_bar_bg = ColorRect.new()
	hp_bar_bg.size = Vector2(BAR_WIDTH, 4)
	hp_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_bg.color = Color(0.12, 0.12, 0.12, 0.9)
	hp_bar_bg.z_index = 10
	add_child(hp_bar_bg)

	hp_bar_fill = ColorRect.new()
	hp_bar_fill.size = Vector2(BAR_WIDTH, 4)
	hp_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	hp_bar_fill.z_index = 10
	add_child(hp_bar_fill)

	skill_bar_bg = ColorRect.new()
	skill_bar_bg.size = Vector2(BAR_WIDTH, 3)
	skill_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_bg.color = Color(0.12, 0.12, 0.12, 0.9)
	skill_bar_bg.z_index = 10
	add_child(skill_bar_bg)

	skill_bar_fill = ColorRect.new()
	skill_bar_fill.size = Vector2(0, 3)
	skill_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_fill.color = Color(1.0, 0.75, 0.2)
	skill_bar_fill.z_index = 10
	add_child(skill_bar_fill)


func _update_hp_bar():
	if hp_bar_fill == null:
		return
	var ratio := float(hp) / float(max_hp)
	hp_bar_fill.size.x = BAR_WIDTH * ratio
	if ratio > 0.5:
		hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	elif ratio > 0.25:
		hp_bar_fill.color = Color(0.9, 0.75, 0.1)
	else:
		hp_bar_fill.color = Color(0.9, 0.2, 0.2)


func take_damage(amount: int):
	var def_avg := (phys_def + magic_def) / 2.0
	var reduced := maxi(1, amount - int(def_avg))
	hp -= reduced
	_update_hp_bar()

	modulate = Color(1.0, 0.4, 0.4)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

	if hp <= 0:
		_die()


func _die():
	for enemy in blocking:
		if is_instance_valid(enemy):
			enemy.clear_blocked()
	emit_signal("spirit_died")
	queue_free()


func _build_live2d_visual(model_path: String):
	is_live2d = true
	live2d_model = ClassDB.instantiate("GDCubismUserModel")
	live2d_model.assets = model_path
	live2d_model.scale = Vector2(0.1, 0.1)
	live2d_model.position = Vector2(0, -20)
	live2d_model.z_index = 1
	add_child(live2d_model)
	base_facing_scale_x = live2d_model.scale.x

	live2d_model.start_motion_loop("Idle", 0, 1, true, true)

	var type_lbl = Label.new()
	type_lbl.text = "M" if unit_type == "melee" else "R"
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override(
		"font_color", Color(1.0, 0.6, 0.1) if unit_type == "melee" else Color(0.3, 0.7, 1.0)
	)
	type_lbl.position = Vector2(-6, -52)
	add_child(type_lbl)


func _build_range_indicator():
	range_circle = Node2D.new()
	range_circle.z_index = -1
	range_circle.visible = false
	add_child(range_circle)
	_refresh_range_indicator()


func _refresh_range_indicator():
	if range_circle == null:
		return
	for child in range_circle.get_children():
		child.queue_free()

	var rotated := _get_rotated_pattern()
	var self_offset := rotated.filter(func(o): return o == Vector2i(0, 0))
	var other_offsets := rotated.filter(func(o): return o != Vector2i(0, 0))

	if self_offset.size() > 0:
		var self_drawer = _PatternDrawer.new()
		self_drawer.tile_size = tile_size
		self_drawer.offsets = self_offset
		self_drawer.fill_color = Color(0.2, 0.4, 1.0, 0.35)
		self_drawer.line_color = Color(0.2, 0.4, 1.0, 0.85)
		self_drawer.z_as_relative = false
		self_drawer.z_index = 2
		range_circle.add_child(self_drawer)

	var drawer = _PatternDrawer.new()
	drawer.tile_size = tile_size
	drawer.offsets = other_offsets
	drawer.fill_color = (
		Color(0.4, 0.8, 1.0, 0.18) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.18)
	)
	drawer.line_color = (
		Color(0.4, 0.8, 1.0, 0.55) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.55)
	)
	range_circle.add_child(drawer)


func _process_melee(delta):
	_try_block_enemies()
	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			for enemy in targets:
				if is_instance_valid(enemy):
					_attack_enemy(enemy)


func _process_ranged(delta):
	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			_attack_enemy(targets[0])


func _find_enemies_in_pattern() -> Array:
	var result := []
	var self_tile := Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	var rotated := _get_rotated_pattern()

	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_tile := Vector2i(
			int(enemy.position.x / tile_size), int(enemy.position.y / tile_size)
		)
		var rel := enemy_tile - self_tile
		if rel in rotated:
			result.append(enemy)

	return result


func _try_block_enemies():
	blocking = blocking.filter(func(e): return is_instance_valid(e) and not e.reached_end)
	if blocking.size() >= block_count:
		return

	var grab_radius := BLOCK_RADIUS_TILES * tile_size
	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy):
			continue
		if blocking.size() >= block_count:
			break
		if enemy in blocking:
			continue
		if enemy.blocked_by != null:
			continue
		if position.distance_to(enemy.position) <= grab_radius:
			blocking.append(enemy)
			enemy.set_blocked(self)


func on_enemy_cleared(enemy: Node2D):
	blocking.erase(enemy)


func _attack_enemy(target: Node2D):
	if not is_instance_valid(target):
		return

	var facing_node: Node2D = live2d_model if is_live2d else anim_sprite
	if facing_node and is_instance_valid(facing_node):
		var facing_left := target.position.x < position.x
		if FACING_FLIP_CORRECTION:
			facing_left = not facing_left
		facing_node.scale.x = (
			-abs(base_facing_scale_x) if facing_left else abs(base_facing_scale_x)
		)

	modulate = Color(1.5, 1.4, 0.5)
	_spawn_projectile(target.position)
	target.take_damage(atk)

	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


func _spawn_projectile(target_pos: Vector2):
	var proj = ColorRect.new()
	proj.size = Vector2(8, 8)
	proj.color = (
		Color(1.0, 0.85, 0.2) if unit_type == "ranged" else Color(1.0, 0.4, 0.2)
	)
	proj.position = position - Vector2(4, 4)
	proj.z_index = 5
	get_parent().add_child(proj)

	var tween = get_tree().create_tween()
	tween.tween_property(proj, "position", target_pos - Vector2(4, 4), 0.16)
	tween.tween_callback(proj.queue_free)


# ============================================================
# INNER CLASS
# ============================================================
class _PatternDrawer:
	extends Node2D
	var tile_size: int = 128
	var offsets: Array = []
	var fill_color: Color = Color(0.4, 0.8, 1.0, 0.18)
	var line_color: Color = Color(0.4, 0.8, 1.0, 0.55)

	func _draw():
		for offset in offsets:
			var top_left := Vector2(
				offset.x * tile_size - tile_size / 2.0, offset.y * tile_size - tile_size / 2.0
			)
			var rect := Rect2(top_left, Vector2(tile_size, tile_size))
			draw_rect(rect, fill_color, true)
			draw_rect(rect, line_color, false, 2.0)