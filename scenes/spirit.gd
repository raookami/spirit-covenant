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

const ELEMENT_COLORS := {
	"Umbra": Color(0.55, 0.18, 0.65),
	"Flare": Color(1.0, 0.68, 0.15),
	"Tide": Color(0.15, 0.48, 0.92),
	"Rime": Color(0.82, 0.92, 1.0),
	"Veil": Color(0.22, 0.85, 0.65),
}

# ============================================================
# VARIABLES (PUBLIC)
# ============================================================
var spirit_id: String = ""
var main_class: String = "Pursuer"
var element: String = "Umbra"
var damage_type: String = "manifest"
var unit_type: String = "melee"
var is_aoe: bool = false
var cp_gen_amount: int = 0
var cp_gen_interval: float = 0.0
var cp_gen_timer: float = 0.0

var hp: int = 500
var max_hp: int = 500
var base_max_hp: int = 500
var atk: int = 1
var base_atk: int = 1
var manifest_def: int = 0
var phantasm_def: int = 0

var attack_patterns: Dictionary = {}
var facing_dir: Vector2i = Vector2i(0, -1)

var attack_cd: float = 1.5
var base_attack_cd: float = 1.5
var block_count: int = 1
var tile_size: int = 128

var battle_ref: Node
var attack_timer: float = 0.0
var blocking: Array = []

var anim_sprite: AnimatedSprite2D
var static_sprite: Sprite2D
var live2d_model: Node2D
var range_circle: Node2D
var is_live2d: bool = false
var base_facing_scale_x: float = 1.0

var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect
var skill_bar_bg: ColorRect
var skill_bar_fill: ColorRect
var shield_border: ColorRect

var is_invincible: bool = false
var link_buff_active: bool = false
var is_revived_by_link: bool = false
var pre_link_hp: int = 0

# ============================================================
# VARIABLES (PRIVATE)
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

	# Penghasil CP berkala (misal Ratora Seer), berhenti saat CP beku
	if cp_gen_amount > 0 and cp_gen_interval > 0.0 and not battle_ref.cp_frozen:
		cp_gen_timer += delta
		if cp_gen_timer >= cp_gen_interval:
			cp_gen_timer = 0.0
			battle_ref.add_cp(cp_gen_amount)

	_update_skill_bar()

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


func init(battle: Node, data: SpiritData):
	assert(data != null, "SpiritData null!")
	assert(data.id != "", "Spirit ID tidak boleh kosong!")
	assert(data.hp > 0, "HP Spirit harus > 0!")
	battle_ref = battle
	spirit_id = data.id
	main_class = data.main_class
	element = data.element
	damage_type = data.damage_type
	unit_type = data.unit_type
	is_aoe = data.is_aoe
	cp_gen_amount = data.cp_gen_amount
	cp_gen_interval = data.cp_gen_interval

	hp = data.hp
	max_hp = hp
	base_max_hp = hp
	atk = data.atk
	base_atk = atk
	manifest_def = data.manifest_def
	phantasm_def = data.phantasm_def
	attack_patterns = data.attack_patterns
	attack_cd = data.atk_spd
	base_attack_cd = attack_cd
	block_count = data.block

	_build_visuals(data.texture_path)
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
	var facing_node := _get_visual_node()
	if facing_node == null or not is_instance_valid(facing_node):
		return
	var face_left := facing_dir.x < 0
	if is_live2d and FACING_FLIP_CORRECTION:
		face_left = not face_left
	facing_node.scale.x = - abs(base_facing_scale_x) if face_left else abs(base_facing_scale_x)


func _get_visual_node() -> Node2D:
	if is_live2d and is_instance_valid(live2d_model):
		return live2d_model
	if (
		is_instance_valid(anim_sprite)
		and anim_sprite.sprite_frames != null
		and anim_sprite.sprite_frames.get_frame_count("idle") > 0
	):
		return anim_sprite
	if is_instance_valid(static_sprite):
		return static_sprite
	return null


func _build_visuals(tex_path: String = ""):
	var model_path := (
		"res://assets/spirites/characters/%s/%s_idle.model3.json" % [spirit_id, spirit_id]
	)
	if ResourceLoader.exists(model_path):
		_build_live2d_visual(model_path)
		_add_type_badge()
		return

	anim_sprite = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 12)

	var loaded_any := false
	for i in range(24):
		var frame_path := (
			"res://assets/spirites/characters/%s/%s_idle_%04d.png" % [spirit_id, spirit_id, i]
		)
		if ResourceLoader.exists(frame_path):
			frames.add_frame("idle", load(frame_path))
			loaded_any = true

	if loaded_any:
		anim_sprite.sprite_frames = frames
		anim_sprite.scale = Vector2(0.6, 0.6)
		anim_sprite.z_index = 1
		anim_sprite.play("idle")
		add_child(anim_sprite)
		base_facing_scale_x = anim_sprite.scale.x
	elif tex_path != "" and ResourceLoader.exists(tex_path):
		var tex: Texture2D = load(tex_path)
		static_sprite = Sprite2D.new()
		static_sprite.texture = tex
		var tex_size := tex.get_size()
		var fit_scale := 82.0 / maxf(1.0, maxf(tex_size.x, tex_size.y))
		static_sprite.scale = Vector2(fit_scale, fit_scale)
		static_sprite.z_index = 1
		add_child(static_sprite)
		base_facing_scale_x = static_sprite.scale.x
	else:
		var placeholder := ColorRect.new()
		placeholder.size = Vector2(52, 52)
		placeholder.position = Vector2(-26, -34)
		placeholder.color = ELEMENT_COLORS.get(element, Color(0.5, 0.5, 0.6))
		add_child(placeholder)

	_add_type_badge()


func _add_type_badge():
	var type_lbl := Label.new()
	var unit_short := "M" if unit_type == "melee" else "R"
	type_lbl.text = "%s [%s]" % [main_class.substr(0, 3).to_upper(), unit_short]
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override("font_color", ELEMENT_COLORS.get(element, Color(1, 1, 1)))
	type_lbl.position = Vector2(-24, -56)
	type_lbl.z_index = 10
	add_child(type_lbl)


func _build_hp_bar():
	shield_border = ColorRect.new()
	shield_border.size = Vector2(BAR_WIDTH + 4, 8)
	shield_border.position = Vector2(-BAR_WIDTH / 2 - 2, BAR_Y_HP - 2)
	shield_border.color = Color(0.55, 0.85, 1.0, 0.95)
	shield_border.z_index = 9
	shield_border.visible = false
	add_child(shield_border)

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
	skill_bar_bg.visible = cp_gen_interval > 0.0
	add_child(skill_bar_bg)

	skill_bar_fill = ColorRect.new()
	skill_bar_fill.size = Vector2(0, 3)
	skill_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_fill.color = Color(1.0, 0.75, 0.2)
	skill_bar_fill.z_index = 10
	skill_bar_fill.visible = cp_gen_interval > 0.0
	add_child(skill_bar_fill)


func _update_hp_bar():
	if hp_bar_fill == null:
		return
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	hp_bar_fill.size.x = BAR_WIDTH * ratio
	if is_invincible:
		hp_bar_fill.color = Color(0.7, 0.95, 1.0)
	elif ratio > 0.5:
		hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	elif ratio > 0.25:
		hp_bar_fill.color = Color(0.9, 0.75, 0.1)
	else:
		hp_bar_fill.color = Color(0.9, 0.2, 0.2)


func _update_skill_bar():
	if skill_bar_fill == null or skill_bar_bg == null:
		return
	if link_buff_active and battle_ref != null:
		skill_bar_bg.visible = true
		skill_bar_fill.visible = true
		skill_bar_fill.color = Color(0.6, 0.9, 1.0)
		var ratio := clampf(battle_ref.covenant_link_timer / 10.0, 0.0, 1.0)
		skill_bar_fill.size.x = BAR_WIDTH * ratio
	elif cp_gen_interval > 0.0:
		skill_bar_bg.visible = true
		skill_bar_fill.visible = true
		skill_bar_fill.color = Color(1.0, 0.75, 0.2)
		var ratio := clampf(cp_gen_timer / cp_gen_interval, 0.0, 1.0)
		skill_bar_fill.size.x = BAR_WIDTH * ratio
	else:
		skill_bar_bg.visible = false
		skill_bar_fill.visible = false


func apply_covenant_link_buff(revived_from_cd: bool):
	if not link_buff_active:
		pre_link_hp = hp
	is_revived_by_link = revived_from_cd
	link_buff_active = true
	is_invincible = true

	max_hp = int(round(float(base_max_hp) * 1.3))
	hp = max_hp
	atk = int(round(float(base_atk) * 1.35))
	attack_cd = base_attack_cd * 0.7

	if shield_border:
		shield_border.visible = true
	_update_hp_bar()
	_update_skill_bar()


func end_covenant_link_buff():
	if not link_buff_active:
		return
	link_buff_active = false
	is_invincible = false

	max_hp = base_max_hp
	atk = base_atk
	attack_cd = base_attack_cd

	if is_revived_by_link:
		hp = maxi(1, int(round(float(base_max_hp) * 0.5)))
	else:
		hp = maxi(1, int(round(float(pre_link_hp) * 0.75)))

	is_revived_by_link = false
	if shield_border:
		shield_border.visible = false
	_update_hp_bar()
	_update_skill_bar()


func take_damage(amount: int, atk_damage_type: String = "manifest"):
	if is_invincible:
		return

	var base_def := manifest_def if atk_damage_type == "manifest" else phantasm_def
	var eff_def := int(round(float(base_def) * 1.5)) if link_buff_active else base_def
	var reduced := maxi(1, amount - eff_def)
	hp = maxi(0, hp - reduced)
	_update_hp_bar()

	if hp <= 0:
		_die()
		return

	modulate = Color(1.0, 0.4, 0.4)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


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
		var self_drawer := _PatternDrawer.new()
		self_drawer.tile_size = tile_size
		self_drawer.offsets = self_offset
		self_drawer.fill_color = Color(0.2, 0.4, 1.0, 0.35)
		self_drawer.line_color = Color(0.2, 0.4, 1.0, 0.85)
		self_drawer.z_as_relative = false
		self_drawer.z_index = 2
		range_circle.add_child(self_drawer)

	var drawer := _PatternDrawer.new()
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
			if is_aoe:
				for enemy in targets:
					if is_instance_valid(enemy):
						_attack_enemy(enemy)
			else:
				var chosen: Node2D = targets[0]
				for b in blocking:
					if b in targets and is_instance_valid(b):
						chosen = b
						break
				_attack_enemy(chosen)


func _process_ranged(delta):
	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			_attack_enemy(targets[0])


func _find_enemies_in_pattern() -> Array:
	var result := []
	var self_tile := Vector2i(floori(position.x / tile_size), floori(position.y / tile_size))
	var rotated := _get_rotated_pattern()

	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy) or enemy.is_dead or not enemy.visible:
			continue
		var enemy_tile := Vector2i(
			floori(enemy.position.x / tile_size), floori(enemy.position.y / tile_size)
		)
		var rel := enemy_tile - self_tile
		if rel in rotated:
			result.append(enemy)

	return result


func _try_block_enemies():
	blocking = blocking.filter(
		func(e): return is_instance_valid(e) and not e.reached_end and not e.is_dead
	)
	if blocking.size() >= block_count:
		return

	var grab_radius := BLOCK_RADIUS_TILES * tile_size
	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy) or enemy.is_dead or not enemy.visible:
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

	var facing_node := _get_visual_node()
	if facing_node and is_instance_valid(facing_node):
		var facing_left := target.position.x < position.x
		if is_live2d and FACING_FLIP_CORRECTION:
			facing_left = not facing_left
		facing_node.scale.x = (
			- abs(base_facing_scale_x) if facing_left else abs(base_facing_scale_x)
		)

	modulate = Color(1.4, 1.3, 0.7)
	if unit_type == "ranged" and battle_ref != null:
		var proj_color: Color = ELEMENT_COLORS.get(element, Color(1.0, 0.85, 0.2))
		battle_ref.spawn_projectile(position, target.position, proj_color)

	target.take_damage(atk, damage_type, element)

	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


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