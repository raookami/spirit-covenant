extends Node2D

enum TileType {PATH, GROUND, HIGH, BLOCKED}

const TILE_SIZE := 128
const RETREAT_COOLDOWN_SEC := 8.0

const TILE_COLORS := {
	TileType.PATH: Color(0.45, 0.28, 0.18, 0.85),
	TileType.GROUND: Color(0.18, 0.28, 0.38, 0.70),
	TileType.HIGH: Color(0.28, 0.40, 0.52, 0.80),
	TileType.BLOCKED: Color(0.08, 0.08, 0.10, 0.95),
}

@export var spirit_roster: Array[SpiritData] = []
@export var enemy_roster: Array[EnemyData] = []
@export var stage_config_path: String = "res://data/chapter/1/stage_01.tres"

var stage: StageConfig
var grid_cols: int = 10
var grid_rows: int = 5
var map_layout: Array = []
var enemy_path: Array = []

var crystal_max_hp: int = 10
var crystal_hp: int = 0
var cp: float = 0.0
var cp_max: int = 99
var cp_regen_rate: float = 1.0
var cp_frozen: bool = false

var occupied_tiles: Dictionary = {}
var deployed_spirits: Array = []
var active_enemies: Array = []
var spirit_deployed: Dictionary = {}
var spirit_retreat_cooldown: Dictionary = {}
var tile_nodes: Dictionary = {}

var battle_over := false
var is_game_paused := false
var user_speed_scale: float = 1.0
var is_slowmo_active := false

var hud: BattleHUD
var deploy_ctrl: DeployController
var spawner: WaveSpawner
var link_ctrl: CovenantLinkController
var vfx: VFXPool

var cam: Camera2D
var default_cam_pos := Vector2(640, 360)
var default_cam_zoom := Vector2(1.0, 1.0)
var _cam_tween: Tween = null


func _ready():
	_load_stage_config()
	if not _validate_data():
		battle_over = true
		return

	for s in spirit_roster:
		spirit_deployed[s.id] = false

	_setup_camera()
	_build_components()
	_draw_grid()

	hud.setup(self)
	hud.update_crystal(crystal_hp, crystal_max_hp)
	hud.update_cp(cp, cp_max, cp_frozen)


func _setup_camera():
	cam = Camera2D.new()
	cam.position = default_cam_pos
	cam.zoom = default_cam_zoom
	add_child(cam)


func _build_components():
	vfx = VFXPool.new()
	add_child(vfx)

	deploy_ctrl = DeployController.new()
	deploy_ctrl.setup(self, TILE_SIZE)
	deploy_ctrl.slowmo_requested.connect(_on_slowmo_requested)
	deploy_ctrl.spirit_deployed_successfully.connect(_on_spirit_deployed)
	deploy_ctrl.retreat_executed.connect(_on_retreat_executed)
	deploy_ctrl.spirit_selected_changed.connect(_on_spirit_selected_changed)
	add_child(deploy_ctrl)

	link_ctrl = CovenantLinkController.new()
	link_ctrl.setup()
	link_ctrl.link_activated.connect(_on_covenant_link_activated)
	link_ctrl.link_ended.connect(_on_covenant_link_ended)
	add_child(link_ctrl)

	spawner = WaveSpawner.new()
	spawner.setup(self, stage.waves, enemy_path, stage.spawn_interval)
	spawner.all_waves_completed.connect(_check_victory_condition)
	add_child(spawner)

	hud = BattleHUD.new()
	hud.speed_toggle_requested.connect(_on_speed_toggle)
	hud.pause_toggle_requested.connect(_on_pause_toggle)
	hud.retreat_requested.connect(deploy_ctrl.execute_retreat_selected)
	hud.skill_requested.connect(deploy_ctrl.execute_skill_selected)
	hud.card_drag_started.connect(deploy_ctrl.handle_card_start_drag)
	add_child(hud)


func _load_stage_config():
	if stage_config_path != "" and ResourceLoader.exists(stage_config_path):
		stage = load(stage_config_path)
	if stage == null:
		grid_cols = 10
		grid_rows = 5
		map_layout = [
			[0, 0, 3, 0, 0, 0, 0, 3, 0, 0],
			[1, 1, 1, 0, 2, 2, 0, 3, 0, 0],
			[3, 3, 1, 0, 2, 2, 0, 1, 1, 1],
			[0, 0, 1, 0, 0, 0, 0, 1, 3, 0],
			[0, 0, 1, 1, 1, 1, 1, 1, 3, 0],
		]
		enemy_path = [
			[0, 1], [1, 1], [2, 1], [2, 2], [2, 3], [2, 4],
			[3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [7, 3],
			[7, 2], [8, 2], [9, 2]
		]
		crystal_max_hp = 10
		cp_max = 99
		cp_regen_rate = 1.0
		cp = 10.0
	else:
		grid_cols = stage.grid_cols
		grid_rows = stage.grid_rows
		map_layout = stage.map_layout
		enemy_path = stage.enemy_path
		crystal_max_hp = stage.crystal_max_hp
		cp_max = stage.cp_max
		cp_regen_rate = stage.cp_regen_rate
		cp = float(stage.cp_start)

	crystal_hp = crystal_max_hp


func _validate_data() -> bool:
	return stage != null and not spirit_roster.is_empty() and not enemy_roster.is_empty()


func _draw_grid():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var tile_type: TileType = map_layout[row][col]
			var tile := ColorRect.new()
			tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			tile.position = Vector2(col * TILE_SIZE + 1, row * TILE_SIZE + 1)
			tile.color = TILE_COLORS[tile_type]
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(tile)
			tile_nodes["%d_%d" % [col, row]] = tile

			if tile_type == TileType.HIGH:
				var lbl := Label.new()
				lbl.text = "▲"
				lbl.add_theme_font_size_override("font_size", 11)
				lbl.position = Vector2(col * TILE_SIZE + 4, row * TILE_SIZE + 4)
				add_child(lbl)


func _process(delta: float):
	if battle_over:
		return

	if not is_game_paused:
		if not cp_frozen:
			cp = minf(cp + cp_regen_rate * delta, float(cp_max))
		hud.update_cp(cp, cp_max, cp_frozen)

		link_ctrl.process_link(delta)
		spawner.process_spawner(delta)

		for sid in spirit_retreat_cooldown.keys():
			spirit_retreat_cooldown[sid] = maxf(
				0.0, spirit_retreat_cooldown[sid] - delta
			)

	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))
	deployed_spirits = deployed_spirits.filter(func(s): return is_instance_valid(s))

	hud.update_cards(cp, spirit_deployed, spirit_retreat_cooldown, spirit_roster)
	hud.update_wave(spawner.get_wave_info())


func _input(event):
	if battle_over:
		return

	if event is InputEventMouseMotion:
		deploy_ctrl.handle_mouse_motion(get_global_mouse_position())

	if deploy_ctrl.choosing_direction:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			if event.pressed:
				deploy_ctrl.handle_direction_press(get_global_mouse_position())
			else:
				deploy_ctrl.handle_mouse_up(get_global_mouse_position())
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				get_viewport().set_input_as_handled()
				deploy_ctrl.cancel_direction_mode()
		return

	if (
		deploy_ctrl.dragging
		and event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		get_viewport().set_input_as_handled()
		deploy_ctrl.handle_mouse_up(get_global_mouse_position())


func _unhandled_input(event):
	if battle_over or deploy_ctrl.choosing_direction or deploy_ctrl.dragging:
		return

	if event is InputEventMouseButton and event.pressed and event.position.y < 640:
		if event.button_index == MOUSE_BUTTON_LEFT:
			deploy_ctrl.handle_arena_click(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			deploy_ctrl.try_retreat_by_mouse(get_global_mouse_position())


# ============================================================
# SPEED, SLOW-MO, & PAUSE CONTROLS
# ============================================================
func _on_speed_toggle():
	user_speed_scale = 1.0 if user_speed_scale > 1.2 else 2.0
	hud.set_speed_text(user_speed_scale)
	_apply_timescale()


func _on_pause_toggle():
	is_game_paused = not is_game_paused
	hud.set_pause_text(is_game_paused)
	_apply_timescale()


func _on_slowmo_requested(active: bool):
	is_slowmo_active = active
	_apply_timescale()


func _apply_timescale():
	if is_game_paused:
		Engine.time_scale = 0.0
	elif is_slowmo_active:
		Engine.time_scale = 0.15
	else:
		Engine.time_scale = user_speed_scale


func focus_camera_on(pos: Vector2, target_zoom: float = 1.18):
	if cam == null:
		return
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = get_tree().create_tween().set_parallel(true)
	_cam_tween.set_ignore_time_scale(true)
	_cam_tween.tween_property(
		cam, "position", pos, 0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_cam_tween.tween_property(
		cam, "zoom", Vector2(target_zoom, target_zoom), 0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func reset_camera():
	if cam == null:
		return
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = get_tree().create_tween().set_parallel(true)
	_cam_tween.set_ignore_time_scale(true)
	_cam_tween.tween_property(
		cam, "position", default_cam_pos, 0.18
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_cam_tween.tween_property(
		cam, "zoom", default_cam_zoom, 0.18
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# ============================================================
# CALLBACKS & PUBLIC HELPERS
# ============================================================
func can_start_drag_spirit(sid: String, cost: int) -> bool:
	if battle_over:
		return false
	if int(cp) < cost:
		return false
	if spirit_deployed.get(sid, false):
		return false
	if spirit_retreat_cooldown.get(sid, 0.0) > 0.0:
		return false
	return true


func get_spirit_data(sid: String) -> SpiritData:
	for s in spirit_roster:
		if s.id == sid:
			return s
	return null


func get_enemy_data(eid: String) -> EnemyData:
	for e in enemy_roster:
		if e.id == eid:
			return e
	return null


func can_deploy_at(col: int, row: int, unit_type: String) -> bool:
	if col < 0 or col >= grid_cols or row < 0 or row >= grid_rows:
		return false
	var t: TileType = map_layout[row][col]
	return (
		(unit_type == "melee" and t == TileType.GROUND)
		or (unit_type == "ranged" and t == TileType.HIGH)
	)


func get_tile_node(key: String):
	return tile_nodes.get(key)


func reset_tile_color(key: String):
	if key == "" or not tile_nodes.has(key):
		return
	var parts := key.split("_")
	var c := int(parts[0])
	var r := int(parts[1])
	if r >= 0 and r < grid_rows and c >= 0 and c < grid_cols:
		tile_nodes[key].color = TILE_COLORS[map_layout[r][c]]


func deduct_cp(amount: int):
	cp = maxf(0.0, cp - float(amount))
	hud.update_cp(cp, cp_max, cp_frozen)


func add_cp(amount: int):
	if cp_frozen or battle_over:
		return
	cp = minf(cp + float(amount), float(cp_max))
	hud.update_cp(cp, cp_max, cp_frozen)


func spawn_projectile(from_pos: Vector2, target_pos: Vector2, color: Color):
	if vfx:
		vfx.spawn_projectile(from_pos, target_pos, color)


func get_link_remaining_time() -> float:
	return link_ctrl.timer if link_ctrl else 0.0


func _on_spirit_deployed(spirit: Node2D, tile_key: String, sid: String):
	spirit_deployed[sid] = true
	occupied_tiles[tile_key] = spirit
	deployed_spirits.append(spirit)
	spirit.connect("spirit_died", _on_spirit_died.bind(spirit))

	if link_ctrl.is_active:
		spirit.apply_covenant_link_buff(false)


func _on_retreat_executed(sid: String, tile_key: String):
	if sid != "":
		spirit_deployed[sid] = false
		spirit_retreat_cooldown[sid] = RETREAT_COOLDOWN_SEC
	if tile_key != "":
		occupied_tiles.erase(tile_key)


func _on_spirit_died(spirit: Node2D):
	if deploy_ctrl.is_redirecting and deploy_ctrl.preview_spirit == spirit:
		deploy_ctrl.cancel_direction_mode()
	elif deploy_ctrl.selected_spirit == spirit:
		deploy_ctrl.deselect_spirit()
	var sid: String = spirit.get_meta("spirit_id", "")
	var tile_key: String = spirit.get_meta("tile_key", "")
	_on_retreat_executed(sid, tile_key)


func _on_spirit_selected_changed(spirit: Node2D):
	hud.update_selected_spirit(spirit)


func _on_covenant_link_activated():
	cp_frozen = true
	hud.update_cp(cp, cp_max, cp_frozen)

	for sid in spirit_retreat_cooldown.keys():
		if spirit_retreat_cooldown[sid] > 0.0:
			spirit_retreat_cooldown[sid] = 0.0

	for s in deployed_spirits:
		if is_instance_valid(s):
			s.apply_covenant_link_buff(false)


func _on_covenant_link_ended():
	cp_frozen = false
	hud.update_cp(cp, cp_max, cp_frozen)

	for s in deployed_spirits:
		if is_instance_valid(s):
			s.end_covenant_link_buff()


func _on_enemy_reached_end(enemy: Node2D):
	if not link_ctrl.link_used:
		if link_ctrl.try_trigger(enemy):
			return

	crystal_hp = maxi(0, crystal_hp - 1)
	hud.update_crystal(crystal_hp, crystal_max_hp)
	enemy.deactivate_to_pool()
	active_enemies.erase(enemy)
	spawner.recycle_enemy(enemy)

	if crystal_hp <= 0 and not battle_over:
		_on_battle_lost()


func _on_enemy_died(enemy: Node2D):
	active_enemies.erase(enemy)
	spawner.recycle_enemy(enemy)
	_check_victory_condition()


func _check_victory_condition():
	var completed := spawner.current_wave_index >= spawner.waves_data.size()
	if completed and active_enemies.is_empty() and not battle_over:
		_on_battle_won()


func _on_battle_won():
	battle_over = true
	deploy_ctrl.cancel_all()
	is_game_paused = false
	is_slowmo_active = false
	Engine.time_scale = 1.0
	var stars := 1
	if crystal_hp == crystal_max_hp:
		stars = 3
	elif crystal_hp > int(crystal_max_hp * 0.5):
		stars = 2
	hud.show_result("VICTORY ★%d" % stars, Color(0.2, 0.9, 0.5))


func _on_battle_lost():
	battle_over = true
	deploy_ctrl.cancel_all()
	is_game_paused = false
	is_slowmo_active = false
	Engine.time_scale = 1.0
	hud.show_result("DEFEAT", Color(0.9, 0.2, 0.2))