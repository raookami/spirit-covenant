extends Node2D

signal enemy_reached_end
signal enemy_died

const ENEMY_TEXTURE = preload("res://assets/spirites/enemies/enemy1.png")

var hp: int = 60
var max_hp: int = 60
var speed: float = 80.0
var tile_size: int = 128
var block_atk: int = 3
var tier: String = "keroco"
var element: String = "Neutral"
var damage_type: String = "manifest"
var manifest_def: int = 0
var phantasm_def: int = 0

var path: Array = []
var path_index: int = 0
var target_pos: Vector2 = Vector2.ZERO
var reached_end: bool = false
var is_dead: bool = false
var blocked_by: Node2D = null
var block_attack_timer: float = 0.0
var block_attack_cd: float = 1.0
var sprite: Sprite2D
var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect


func _ready():
	_build_visuals()
	if path.size() > 0:
		_init_position()


func setup(enemy_path: Array, data: EnemyData):
	assert(data != null, "EnemyData null! File .tres musuh tidak valid.")
	assert(data.hp > 0, "HP musuh harus lebih dari 0! Cek file .tres: " + data.id)
	assert(enemy_path.size() > 1, "Path musuh terlalu pendek! Minimal 2 waypoint.")

	path = enemy_path
	path_index = 0
	reached_end = false
	is_dead = false
	blocked_by = null
	block_attack_timer = 0.0
	modulate = Color(1, 1, 1)

	hp = data.hp
	max_hp = hp
	speed = data.speed
	block_atk = data.block_atk
	tier = data.tier
	element = data.element
	damage_type = data.damage_type
	manifest_def = data.manifest_def
	phantasm_def = data.phantasm_def

	if sprite != null:
		if data.texture_path != "" and ResourceLoader.exists(data.texture_path):
			sprite.texture = load(data.texture_path)
		else:
			sprite.texture = ENEMY_TEXTURE
		sprite.scale.x = abs(sprite.scale.x)

	if hp_bar_fill != null:
		_update_hp_bar()

	visible = true
	set_process(true)
	_init_position()


func _process(delta):
	if reached_end or is_dead:
		return

	if blocked_by != null:
		if not is_instance_valid(blocked_by):
			blocked_by = null
		else:
			block_attack_timer += delta
			if block_attack_timer >= block_attack_cd:
				block_attack_timer = 0.0
				_attack_blocker()
			return

	if path.size() == 0 or path_index == 0:
		return

	var dir := (target_pos - position).normalized()
	position += dir * speed * delta

	if dir.x < -0.1:
		sprite.scale.x = - abs(sprite.scale.x)
	elif dir.x > 0.1:
		sprite.scale.x = abs(sprite.scale.x)

	if position.distance_to(target_pos) < 4.0:
		position = target_pos
		path_index += 1
		if path_index >= path.size():
			reached_end = true
			emit_signal("enemy_reached_end")
			return
		target_pos = Vector2(
			path[path_index][0] * tile_size + tile_size / 2.0,
			path[path_index][1] * tile_size + tile_size / 2.0
		)


func _build_visuals():
	sprite = Sprite2D.new()
	sprite.texture = ENEMY_TEXTURE
	sprite.scale = Vector2(0.5, 0.5)
	add_child(sprite)

	hp_bar_bg = ColorRect.new()
	hp_bar_bg.size = Vector2(46, 6)
	hp_bar_bg.position = Vector2(-23, -50)
	hp_bar_bg.color = Color(0.12, 0.12, 0.12, 0.9)
	add_child(hp_bar_bg)

	hp_bar_fill = ColorRect.new()
	hp_bar_fill.size = Vector2(46, 6)
	hp_bar_fill.position = Vector2(-23, -50)
	hp_bar_fill.color = Color(0.15, 0.85, 0.3)
	add_child(hp_bar_fill)


func _update_hp_bar():
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	hp_bar_fill.size.x = 46.0 * ratio
	if ratio > 0.5:
		hp_bar_fill.color = Color(0.15, 0.85, 0.3)
	elif ratio > 0.25:
		hp_bar_fill.color = Color(0.9, 0.75, 0.1)
	else:
		hp_bar_fill.color = Color(0.9, 0.2, 0.2)


func _init_position():
	if path.size() < 2:
		return
	position = Vector2(
		path[0][0] * tile_size + tile_size / 2.0, path[0][1] * tile_size + tile_size / 2.0
	)
	path_index = 1
	target_pos = Vector2(
		path[1][0] * tile_size + tile_size / 2.0, path[1][1] * tile_size + tile_size / 2.0
	)


func _attack_blocker():
	if not is_instance_valid(blocked_by):
		return
	blocked_by.take_damage(block_atk, damage_type)
	modulate = Color(1.0, 0.6, 0.6)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self) and not is_dead and visible:
		modulate = Color(1, 1, 1)


func set_blocked(spirit: Node2D):
	if blocked_by != null or is_dead or reached_end:
		return
	blocked_by = spirit


func clear_blocked():
	blocked_by = null
	block_attack_timer = 0.0


func push_back_tiles(tiles: int):
	if path.size() < 2 or is_dead:
		return
	reached_end = false
	if blocked_by != null and is_instance_valid(blocked_by):
		blocked_by.on_enemy_cleared(self)
	clear_blocked()

	var back_idx := clampi((path.size() - 1) - tiles, 0, path.size() - 2)
	position = Vector2(
		path[back_idx][0] * tile_size + tile_size / 2.0,
		path[back_idx][1] * tile_size + tile_size / 2.0
	)
	path_index = back_idx + 1
	target_pos = Vector2(
		path[path_index][0] * tile_size + tile_size / 2.0,
		path[path_index][1] * tile_size + tile_size / 2.0
	)
	modulate = Color(0.6, 0.85, 1.0)
	visible = true
	set_process(true)
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(self) and not is_dead and visible:
		modulate = Color(1, 1, 1)


func deactivate_to_pool():
	reached_end = true
	clear_blocked()
	visible = false
	set_process(false)
	modulate = Color(1, 1, 1)


func _get_element_multiplier(atk_elem: String, def_elem: String) -> float:
	if atk_elem == "Neutral" or def_elem == "Neutral" or atk_elem == def_elem:
		return 1.0
	if (
		(atk_elem == "Veil" and def_elem == "Tide")
		or (atk_elem == "Tide" and def_elem == "Rime")
		or (atk_elem == "Rime" and def_elem == "Veil")
	):
		return 1.2
	if (
		(atk_elem == "Tide" and def_elem == "Veil")
		or (atk_elem == "Rime" and def_elem == "Tide")
		or (atk_elem == "Veil" and def_elem == "Rime")
	):
		return 0.85
	if (atk_elem == "Umbra" and def_elem == "Flare") or (atk_elem == "Flare" and def_elem == "Umbra"):
		return 1.2
	return 1.0


func take_damage(
	amount: int,
	atk_damage_type: String = "manifest",
	atk_element: String = "Neutral"
):
	if is_dead or reached_end or not visible:
		return

	var def_val := manifest_def if atk_damage_type == "manifest" else phantasm_def
	var base_dmg := maxi(1, amount - def_val)
	var elem_mult := _get_element_multiplier(atk_element, element)
	var final_dmg := maxi(1, int(round(float(base_dmg) * elem_mult)))

	hp = maxi(0, hp - final_dmg)
	_update_hp_bar()

	if hp <= 0:
		is_dead = true
		if blocked_by != null and is_instance_valid(blocked_by):
			blocked_by.on_enemy_cleared(self)
		blocked_by = null
		emit_signal("enemy_died")
		deactivate_to_pool()
		return

	modulate = Color(1.0, 0.3, 0.3)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self) and not is_dead and visible:
		modulate = Color(1, 1, 1)