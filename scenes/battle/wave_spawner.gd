class_name WaveSpawner
extends Node2D

signal all_waves_completed

const WAVE_BREAK_SEC := 5.0

var battle_ref: Node = null
var waves_data: Array = []
var enemy_path: Array = []
var spawn_interval: float = 3.0

var current_wave_index: int = 0
var enemies_spawned_in_wave: int = 0
var wave_timer: float = 0.0
var waiting_next_wave: bool = false

var enemy_pool: Array = []


func setup(battle: Node, waves: Array, path: Array, interval: float):
	battle_ref = battle
	waves_data = waves
	enemy_path = path
	spawn_interval = interval
	current_wave_index = 0
	enemies_spawned_in_wave = 0
	wave_timer = 0.0
	waiting_next_wave = false


func process_spawner(delta: float):
	if current_wave_index >= waves_data.size():
		return

	wave_timer += delta
	if waiting_next_wave:
		if wave_timer >= WAVE_BREAK_SEC:
			waiting_next_wave = false
			wave_timer = 0.0
			current_wave_index += 1
			enemies_spawned_in_wave = 0
			if current_wave_index < waves_data.size():
				_spawn_one_enemy()
			else:
				emit_signal("all_waves_completed")
	else:
		if wave_timer >= spawn_interval:
			wave_timer = 0.0
			_spawn_one_enemy()


func _spawn_one_enemy():
	if current_wave_index >= waves_data.size():
		return

	var current_wave: Dictionary = waves_data[current_wave_index]
	var enemy_id := str(current_wave["type"])
	var enemy_data: EnemyData = battle_ref.get_enemy_data(enemy_id)

	enemies_spawned_in_wave += 1

	if enemy_data == null:
		push_error("WaveSpawner: Enemy ID '%s' tidak ditemukan di roster!" % enemy_id)
	else:
		var enemy: Node2D
		if enemy_pool.size() > 0:
			enemy = enemy_pool.pop_back()
		else:
			enemy = Node2D.new()
			enemy.set_script(load("res://scenes/entities/enemy.gd"))
			battle_ref.add_child(enemy)
			enemy.connect("enemy_reached_end", battle_ref._on_enemy_reached_end.bind(enemy))
			enemy.connect("enemy_died", battle_ref._on_enemy_died.bind(enemy))

		enemy.setup(enemy_path, enemy_data)
		battle_ref.active_enemies.append(enemy)

	if enemies_spawned_in_wave >= int(current_wave["count"]):
		if current_wave_index + 1 >= waves_data.size():
			current_wave_index = waves_data.size()
			emit_signal("all_waves_completed")
		else:
			waiting_next_wave = true
			wave_timer = 0.0


func recycle_enemy(enemy: Node2D):
	if is_instance_valid(enemy) and not enemy_pool.has(enemy):
		enemy_pool.append(enemy)


func get_wave_info() -> Dictionary:
	var total := waves_data.size()
	var cur := mini(current_wave_index + 1, total)
	var remain_break := ceili(maxf(0.0, WAVE_BREAK_SEC - wave_timer))
	return {
		"current": cur,
		"total": total,
		"waiting": waiting_next_wave,
		"break_remain": remain_break,
	}