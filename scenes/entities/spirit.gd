extends Node2D

signal spirit_died

const BLOCK_RADIUS_TILES := 0.6

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
var visual_comp: SpiritVisual
var range_circle: Node2D
var attack_timer: float = 0.0
var blocking: Array = []

var is_invincible: bool = false
var link_buff_active: bool = false
var is_revived_by_link: bool = false
var pre_link_hp: int = 0


func _ready():
	_build_range_indicator()


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

	visual_comp = SpiritVisual.new()
	add_child(visual_comp)
	visual_comp.setup(self, data)


func _process(delta: float):
	if battle_ref == null:
		return

	if cp_gen_amount > 0 and cp_gen_interval > 0.0 and not battle_ref.cp_frozen:
		cp_gen_timer += delta
		if cp_gen_timer >= cp_gen_interval:
			cp_gen_timer = 0.0
			battle_ref.add_cp(cp_gen_amount)

	var link_t: float = battle_ref.get_link_remaining_time()
	if visual_comp:
		visual_comp.update_skill_bar(
			cp_gen_timer, cp_gen_interval, link_buff_active, link_t
		)

	if unit_type == "melee":
		_process_melee(delta)
	else:
		_process_ranged(delta)


func set_facing(dir: Vector2i):
	facing_dir = dir
	if visual_comp:
		visual_comp.apply_facing(facing_dir)
	if range_circle:
		_refresh_range_indicator()


func toggle_range_indicator(should_show: bool):
	if range_circle:
		range_circle.visible = should_show


func trigger_skill():
	modulate = Color(0.7, 0.95, 1.4)
	await get_tree().create_timer(0.15, true, false, true).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


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

	if visual_comp:
		visual_comp.set_shield_visible(true)
		visual_comp.update_hp_bar(hp, max_hp, is_invincible)


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
	if visual_comp:
		visual_comp.set_shield_visible(false)
		visual_comp.update_hp_bar(hp, max_hp, is_invincible)


func take_damage(amount: int, atk_damage_type: String = "manifest"):
	if is_invincible:
		return

	var base_def := manifest_def if atk_damage_type == "manifest" else phantasm_def
	var eff_def := int(round(float(base_def) * 1.5)) if link_buff_active else base_def
	var reduced := maxi(1, amount - eff_def)
	hp = maxi(0, hp - reduced)

	if visual_comp:
		visual_comp.update_hp_bar(hp, max_hp, is_invincible)

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
	if unit_type == "ranged":
		drawer.fill_color = Color(0.4, 0.8, 1.0, 0.18)
		drawer.line_color = Color(0.4, 0.8, 1.0, 0.55)
	else:
		drawer.fill_color = Color(1.0, 0.6, 0.2, 0.18)
		drawer.line_color = Color(1.0, 0.6, 0.2, 0.55)
	range_circle.add_child(drawer)


func _process_melee(delta: float):
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


func _process_ranged(delta: float):
	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			_attack_enemy(targets[0])


func _find_enemies_in_pattern() -> Array:
	var result := []
	var self_tile := Vector2i(
		floori(position.x / tile_size), floori(position.y / tile_size)
	)
	var rotated := _get_rotated_pattern()
	for pt in rotated:
		var target_tile: Vector2i = self_tile + pt
		for enemy in battle_ref.active_enemies:
			if not is_instance_valid(enemy) or enemy.is_dead or not enemy.visible:
				continue
			var ex := floori(enemy.position.x / tile_size)
			var ey := floori(enemy.position.y / tile_size)
			var enemy_tile := Vector2i(ex, ey)
			if enemy_tile == target_tile and enemy not in result:
				result.append(enemy)
	for blocked_enemy in blocking:
		if (
			is_instance_valid(blocked_enemy)
			and not blocked_enemy.is_dead
			and blocked_enemy.visible
			and blocked_enemy not in result
		):
			result.append(blocked_enemy)
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
		if enemy in blocking or enemy.blocked_by != null:
			continue
		if position.distance_to(enemy.position) <= grab_radius:
			blocking.append(enemy)
			enemy.set_blocked(self)


func on_enemy_cleared(enemy: Node2D):
	blocking.erase(enemy)


func _attack_enemy(target: Node2D):
	if not is_instance_valid(target):
		return

	if unit_type == "melee" and visual_comp:
		var facing_left := target.position.x < position.x
		visual_comp.apply_facing(
			Vector2i(-1, 0) if facing_left else Vector2i(1, 0)
		)

	modulate = Color(1.4, 1.3, 0.7)
	if unit_type == "ranged" and battle_ref != null:
		var proj_color := Color(1.0, 0.85, 0.2)
		if SpiritVisual.ELEMENT_COLORS.has(element):
			proj_color = SpiritVisual.ELEMENT_COLORS[element]
		battle_ref.spawn_projectile(position, target.position, proj_color)

	target.take_damage(atk, damage_type, element)

	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


class _PatternDrawer:
	extends Node2D
	var tile_size: int = 128
	var offsets: Array = []
	var fill_color: Color = Color(0.4, 0.8, 1.0, 0.18)
	var line_color: Color = Color(0.4, 0.8, 1.0, 0.55)

	func _draw():
		for offset in offsets:
			var top_left := Vector2(
				offset.x * tile_size - tile_size / 2.0,
				offset.y * tile_size - tile_size / 2.0
			)
			var rect := Rect2(top_left, Vector2(tile_size, tile_size))
			draw_rect(rect, fill_color, true)
			draw_rect(rect, line_color, false, 2.0)