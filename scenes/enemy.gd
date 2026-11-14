extends Node2D

signal enemy_reached_end
signal enemy_died

const ENEMY_TEXTURE = preload("res://assets/spirites/enemies/enemy1.png")

var hp: int = 60
var max_hp: int = 60
var speed: float = 80.0
var tile_size: int = 128
var block_atk: int = 3
var path: Array = []
var path_index: int = 0
var target_pos: Vector2 = Vector2.ZERO
var reached_end: bool = false
var blocked_by: Node2D = null
var block_attack_timer: float = 0.0
var block_attack_cd: float = 1.0
var sprite: Sprite2D
var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect

var _initialized: bool = false


func _ready():
	_initialized = true
	_build_visuals()
	if path.size() > 0:
		_init_position()


func setup(enemy_path: Array, data: EnemyData):
	path = enemy_path
	path_index = 0
	reached_end = false
	blocked_by = null

	# Ambil data dari Resource EnemyData
	hp = data.hp
	max_hp = hp
	speed = data.speed
	block_atk = data.block_atk

	# Pastikan HP bar di-reset
	if hp_bar_fill != null:
		_update_hp_bar()

	visible = true
	set_process(true)
	_init_position()


func _process(delta):
	if reached_end:
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
		sprite.scale.x = -abs(sprite.scale.x)
	elif dir.x > 0.1:
		sprite.scale.x = abs(sprite.scale.x)

	if position.distance_to(target_pos) < 4.0:
		position = target_pos
		path_index += 1
		if path_index >= path.size():
			reached_end = true
			emit_signal("enemy_reached_end")
			visible = false
			set_process(false)
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
	var ratio := float(hp) / float(max_hp)
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
	blocked_by.take_damage(block_atk)
	modulate = Color(1.0, 0.6, 0.6)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)


func set_blocked(spirit: Node2D):
	if blocked_by != null:
		return
	blocked_by = spirit


func clear_blocked():
	blocked_by = null
	block_attack_timer = 0.0


func take_damage(amount: int):
	hp -= amount
	_update_hp_bar()

	modulate = Color(1.0, 0.3, 0.3)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

	if hp <= 0:
		if blocked_by != null and is_instance_valid(blocked_by):
			blocked_by.on_enemy_cleared(self)
		emit_signal("enemy_died")
		visible = false
		set_process(false)
