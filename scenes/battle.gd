extends Node2D

# ============================================================
# 1. ENUM
# ============================================================
enum TileType { PATH, GROUND, HIGH, BLOCKED }

# ============================================================
# 2. CONSTANTS
# ============================================================
const TILE_SIZE := 128
const RETREAT_COOLDOWN_SEC := 8.0

const TILE_COLORS = {
	TileType.PATH: Color(0.45, 0.28, 0.18, 0.85),
	TileType.GROUND: Color(0.18, 0.28, 0.38, 0.70),
	TileType.HIGH: Color(0.28, 0.40, 0.52, 0.80),
	TileType.BLOCKED: Color(0.08, 0.08, 0.10, 0.95),
}

const SPIRIT_ROSTER = [
	{
		"id": "raookami",
		"name": "Raoo",
		"unit_type": "melee",
		"cost": 8,
		"block": 1,
		"hp": 800,
		"atk": 45,
		"phys_def": 30,
		"magic_def": 20,
		"attack_patterns":
		{
			"up": [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
			"right": [Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
			"down": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
			"left": [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1)],
		},
		"atk_spd": 1.0 / 2.0,
		"texture": "res://assets/spirites/characters/raookami/raookami.png",
	},
	{
		"id": "kuma",
		"name": "Kuma",
		"unit_type": "melee",
		"cost": 12,
		"block": 3,
		"hp": 1200,
		"atk": 25,
		"phys_def": 60,
		"magic_def": 40,
		"attack_patterns":
		{
			"up":
			[
				Vector2i(-1, -1),
				Vector2i(0, -1),
				Vector2i(1, -1),
				Vector2i(-1, 0),
				Vector2i(0, 0),
				Vector2i(1, 0)
			],
			"right":
			[
				Vector2i(1, -1),
				Vector2i(1, 0),
				Vector2i(1, 1),
				Vector2i(0, -1),
				Vector2i(0, 0),
				Vector2i(0, 1)
			],
			"down":
			[
				Vector2i(1, 1),
				Vector2i(0, 1),
				Vector2i(-1, 1),
				Vector2i(1, 0),
				Vector2i(0, 0),
				Vector2i(-1, 0)
			],
			"left":
			[
				Vector2i(-1, 1),
				Vector2i(-1, 0),
				Vector2i(-1, -1),
				Vector2i(0, 1),
				Vector2i(0, 0),
				Vector2i(0, -1)
			],
		},
		"atk_spd": 1.0 / 0.8,
		"texture": "res://assets/spirites/characters/kuma/kuma.png",
	},
	{
		"id": "yoshiki",
		"name": "Shiki",
		"unit_type": "ranged",
		"cost": 10,
		"block": 0,
		"hp": 350,
		"atk": 70,
		"phys_def": 10,
		"magic_def": 15,
		"attack_patterns":
		{
			"up":
			[Vector2i(0, 0), Vector2i(0, -1), Vector2i(0, -2), Vector2i(0, -3), Vector2i(0, -4)],
			"right":
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)],
			"down":
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4)],
			"left":
			[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-2, 0), Vector2i(-3, 0), Vector2i(-4, 0)],
		},
		"atk_spd": 1.0 / 1.6,
		"texture": "res://assets/spirites/characters/yoshiki/yoshiki.png",
	},
	{
		"id": "ratora",
		"name": "Tora",
		"unit_type": "melee",
		"cost": 9,
		"block": 2,
		"hp": 550,
		"atk": 75,
		"phys_def": 15,
		"magic_def": 10,
		"attack_patterns":
		{
			"up":
			[Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)],
			"right":
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0)],
			"down":
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)],
			"left":
			[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0)],
		},
		"atk_spd": 1.0 / 1.8,
		"texture": "res://assets/spirites/characters/ratora/ratora.png",
	},
	{
		"id": "koyuuki",
		"name": "Yuki",
		"unit_type": "ranged",
		"cost": 11,
		"block": 0,
		"hp": 550,
		"atk": 45,
		"phys_def": 10,
		"magic_def": 20,
		"attack_patterns":
		{
			"up":
			[
				Vector2i(0, 0),
				Vector2i(0, -1),
				Vector2i(0, -2),
				Vector2i(-1, -1),
				Vector2i(1, -1),
				Vector2i(-1, -2),
				Vector2i(1, -2)
			],
			"right":
			[
				Vector2i(0, 0),
				Vector2i(1, 0),
				Vector2i(2, 0),
				Vector2i(1, -1),
				Vector2i(1, 1),
				Vector2i(2, -1),
				Vector2i(2, 1)
			],
			"down":
			[
				Vector2i(0, 0),
				Vector2i(0, 1),
				Vector2i(0, 2),
				Vector2i(1, 1),
				Vector2i(-1, 1),
				Vector2i(1, 2),
				Vector2i(-1, 2)
			],
			"left":
			[
				Vector2i(0, 0),
				Vector2i(-1, 0),
				Vector2i(-2, 0),
				Vector2i(-1, 1),
				Vector2i(-1, -1),
				Vector2i(-2, 1),
				Vector2i(-2, -1)
			],
		},
		"atk_spd": 1.0 / 2.2,
		"texture": "res://assets/spirites/characters/koyuuki/koyuuki.png",
	},
]

# ============================================================
# 3. EXPORTED VARIABLES
# ============================================================
@export var stage_config_path: String = "res://data/stage_01.tres"

# ============================================================
# 4. VARIABLES
# ============================================================
var stage: StageConfig

var grid_cols: int = 10
var grid_rows: int = 5
var map_layout: Array = []
var enemy_path: Array = []

var crystal_max_hp: int = 10
var spawn_interval: float = 3.0
var max_enemies: int = 8

var dp_max: int = 99
var dp_regen_rate: float = 1.0
var dp_start: int = 10

var occupied_tiles: Dictionary = {}
var deployed_spirits: Array = []
var spirit_deployed: Dictionary = {}
var spirit_retreat_cooldown: Dictionary = {}

var tile_nodes: Dictionary = {}
var dp: float = 0.0
var dp_label: Label = null
var dp_bar_fill: ColorRect = null
var crystal_hp: int = 0
var crystal_hp_label: Label = null

var wave_timer: float = 0.0
var enemies_spawned: int = 0
var active_enemies: Array = []
var enemy_pool: Array = []
var battle_over := false
var waves_data: Array = []
var current_wave_index: int = 0
var enemies_spawned_in_wave: int = 0
var wave_label: Label = null

var dragging := false
var drag_spirit_id := ""
var drag_sprite: Sprite2D = null
var card_nodes: Dictionary = {}

var choosing_direction := false
var pending_deploy_data: Dictionary = {}
var pending_deploy_tile: Vector2i = Vector2i.ZERO
var direction_buttons: Array = []

var _last_highlighted_tile: String = ""


# ============================================================
# 5. FUNCTIONS
# ============================================================
func _ready():
	_load_stage_config()

	for s in SPIRIT_ROSTER:
		spirit_deployed[s["id"]] = false

	_draw_grid()
	_create_bottom_panel()
	_create_hud()


func _load_stage_config():
	if stage_config_path != "" and ResourceLoader.exists(stage_config_path):
		stage = load(stage_config_path)
	if stage == null:
		push_warning(
			"StageConfig gagal di-load dari '%s' — pakai fallback default." % stage_config_path
		)
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
			[0, 1],
			[1, 1],
			[2, 1],
			[2, 2],
			[2, 3],
			[2, 4],
			[3, 4],
			[4, 4],
			[5, 4],
			[6, 4],
			[7, 4],
			[7, 3],
			[7, 2],
			[8, 2],
			[9, 2]
		]
		crystal_max_hp = 10
		spawn_interval = 3.0
		max_enemies = 8
		dp_max = 99
		dp_regen_rate = 1.0
		dp_start = 10
	else:
		grid_cols = stage.grid_cols
		grid_rows = stage.grid_rows
		map_layout = stage.map_layout
		enemy_path = stage.enemy_path
		crystal_max_hp = stage.crystal_max_hp
		spawn_interval = stage.spawn_interval
		max_enemies = stage.max_enemies
		dp_max = stage.dp_max
		dp_regen_rate = stage.dp_regen_rate
		dp_start = stage.dp_start
		if stage.waves.is_empty():
			waves_data = [{"type": 0, "count": 3}, {"type": 2, "count": 4}, {"type": 1, "count": 2}]
		else:
			waves_data = stage.waves

	dp = float(dp_start)
	crystal_hp = crystal_max_hp


func _draw_grid():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var tile_type: TileType = map_layout[row][col]
			var tile = ColorRect.new()
			tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			tile.position = Vector2(col * TILE_SIZE + 1, row * TILE_SIZE + 1)
			tile.color = TILE_COLORS[tile_type]
			add_child(tile)
			tile_nodes["%d_%d" % [col, row]] = tile

			if tile_type == TileType.HIGH:
				var lbl = Label.new()
				lbl.text = "▲"
				lbl.add_theme_font_size_override("font_size", 11)
				lbl.position = Vector2(col * TILE_SIZE + 4, row * TILE_SIZE + 4)
				add_child(lbl)


func _create_bottom_panel():
	var panel_y := grid_rows * TILE_SIZE

	var bg = ColorRect.new()
	bg.size = Vector2(1280, 100)
	bg.position = Vector2(0, panel_y)
	bg.color = Color(0.06, 0.06, 0.10, 0.96)
	add_child(bg)

	var border = ColorRect.new()
	border.size = Vector2(1280, 2)
	border.position = Vector2(0, panel_y)
	border.color = Color(0.35, 0.55, 0.75, 0.7)
	add_child(border)

	for i in range(SPIRIT_ROSTER.size()):
		var data = SPIRIT_ROSTER[i]
		_create_spirit_card(data, i, panel_y)


func _create_spirit_card(data: Dictionary, index: int, panel_y: int):
	var card_x := 20 + index * 110
	var card_y := panel_y + 8

	var card = Node2D.new()
	card.name = "Card_" + data["id"]
	add_child(card)
	card_nodes[data["id"]] = card
	card.set_meta("card_center", Vector2(card_x + 34, card_y + 30))

	var card_bg = ColorRect.new()
	card_bg.size = Vector2(96, 84)
	card_bg.position = Vector2(card_x, card_y)
	card_bg.color = Color(0.12, 0.16, 0.22, 0.95)
	card.add_child(card_bg)

	var card_border = ColorRect.new()
	card_border.size = Vector2(96, 2)
	card_border.position = Vector2(card_x, card_y)
	var border_color = (
		Color(0.9, 0.5, 0.1) if data["unit_type"] == "melee" else Color(0.2, 0.6, 1.0)
	)
	card_border.color = border_color
	card.add_child(card_border)

	var tex_path: String = data["texture"]
	if ResourceLoader.exists(tex_path):
		var icon = Sprite2D.new()
		icon.texture = load(tex_path)
		icon.scale = Vector2(0.25, 0.25)
		icon.position = Vector2(card_x + 48, card_y + 36)
		card.add_child(icon)
	else:
		var placeholder = ColorRect.new()
		placeholder.size = Vector2(60, 50)
		placeholder.position = Vector2(card_x + 18, card_y + 8)
		placeholder.color = Color(0.2, 0.3, 0.4)
		card.add_child(placeholder)

	var name_lbl = Label.new()
	name_lbl.text = data["name"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.position = Vector2(card_x + 4, card_y + 64)
	card.add_child(name_lbl)

	var cost_lbl = Label.new()
	cost_lbl.text = "DP %d" % data["cost"]
	cost_lbl.add_theme_font_size_override("font_size", 10)
	cost_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 0.5))
	cost_lbl.position = Vector2(card_x + 4, card_y + 4)
	card.add_child(cost_lbl)

	var type_lbl = Label.new()
	type_lbl.text = "M" if data["unit_type"] == "melee" else "R"
	type_lbl.add_theme_font_size_override("font_size", 10)
	var type_color = Color(0.9, 0.5, 0.1) if data["unit_type"] == "melee" else Color(0.2, 0.6, 1.0)
	type_lbl.add_theme_color_override("font_color", type_color)
	type_lbl.position = Vector2(card_x + 78, card_y + 4)
	card.add_child(type_lbl)


func _create_hud():
	var hud_bg = ColorRect.new()
	hud_bg.size = Vector2(230, 36)
	hud_bg.position = Vector2(8, 8)
	hud_bg.color = Color(0, 0, 0, 0.55)
	add_child(hud_bg)

	crystal_hp_label = Label.new()
	crystal_hp_label.text = _crystal_text()
	crystal_hp_label.add_theme_font_size_override("font_size", 15)
	crystal_hp_label.position = Vector2(14, 12)
	add_child(crystal_hp_label)

	var dp_bg = ColorRect.new()
	dp_bg.size = Vector2(230, 36)
	dp_bg.position = Vector2(8, 50)
	dp_bg.color = Color(0, 0, 0, 0.55)
	add_child(dp_bg)

	var dp_track = ColorRect.new()
	dp_track.size = Vector2(160, 10)
	dp_track.position = Vector2(14, 68)
	dp_track.color = Color(0.2, 0.2, 0.2)
	add_child(dp_track)

	dp_bar_fill = ColorRect.new()
	dp_bar_fill.size = Vector2(0, 10)
	dp_bar_fill.position = Vector2(14, 68)
	dp_bar_fill.color = Color(0.5, 0.85, 1.0)
	add_child(dp_bar_fill)

	dp_label = Label.new()
	dp_label.text = "DP: %d / %d" % [int(dp), dp_max]
	dp_label.add_theme_font_size_override("font_size", 13)
	dp_label.position = Vector2(180, 60)
	add_child(dp_label)

		# === Wave UI ===
	wave_label = Label.new()
	wave_label.text = "Wave: 0/0"
	wave_label.add_theme_font_size_override("font_size", 16)
	wave_label.position = Vector2(1100, 12)
	add_child(wave_label)


func _crystal_text() -> String:
	return "💎 Crystal: %d / %d" % [crystal_hp, crystal_max_hp]


func _update_crystal_hud():
	if not crystal_hp_label:
		return
	crystal_hp_label.text = _crystal_text()
	if crystal_hp <= 3:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	elif crystal_hp <= 6:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	else:
		crystal_hp_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.9))


func _update_dp_hud():
	if dp_label:
		dp_label.text = "DP: %d / %d" % [int(dp), dp_max]
	if dp_bar_fill:
		dp_bar_fill.size.x = 160.0 * (dp / float(dp_max))


func _process(delta):
	if battle_over:
		return

	dp = minf(dp + dp_regen_rate * delta, float(dp_max))
	_update_dp_hud()
	_refresh_card_availability()

		# Spawn enemy
	if current_wave_index < waves_data.size():
		wave_timer += delta
		if wave_timer >= spawn_interval:
			wave_timer = 0.0
			_spawn_enemy()
	# Update UI Wave
	if wave_label:
		var display_wave = min(current_wave_index + 1, waves_data.size())
		var total_waves = waves_data.size()
		wave_label.text = "Wave: %d / %d" % [display_wave, total_waves]
	# Bersihkan node invalid
	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))
	deployed_spirits = deployed_spirits.filter(func(s): return is_instance_valid(s))

	for sid in spirit_retreat_cooldown.keys():
		spirit_retreat_cooldown[sid] = maxf(0.0, spirit_retreat_cooldown[sid] - delta)

	# Cek menang
	if current_wave_index >= waves_data.size() and active_enemies.is_empty() and not battle_over:
		_on_battle_won()

	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))
	deployed_spirits = deployed_spirits.filter(func(s): return is_instance_valid(s))

	for sid in spirit_retreat_cooldown.keys():
		spirit_retreat_cooldown[sid] = maxf(0.0, spirit_retreat_cooldown[sid] - delta)

	if enemies_spawned >= max_enemies and active_enemies.is_empty():
		_on_battle_won()


func _refresh_card_availability():
	for data in SPIRIT_ROSTER:
		var sid: String = data["id"]
		var card = card_nodes.get(sid)
		if card == null:
			continue
		var can_afford: bool = int(dp) >= data["cost"]
		var is_deployed: bool = spirit_deployed.get(sid, false)
		var cooldown: float = spirit_retreat_cooldown.get(sid, 0.0)
		var is_ready: bool = can_afford and not is_deployed and cooldown <= 0.0

		card.modulate = Color(1, 1, 1, 1) if is_ready else Color(0.4, 0.4, 0.4, 0.7)

		var cd_lbl: Label = card.get_node_or_null("CooldownLabel")
		if cooldown > 0.0:
			if cd_lbl == null:
				cd_lbl = Label.new()
				cd_lbl.name = "CooldownLabel"
				cd_lbl.add_theme_font_size_override("font_size", 18)
				cd_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
				card.add_child(cd_lbl)
			cd_lbl.text = "%ds" % int(ceil(cooldown))
			cd_lbl.position = card.get_meta("card_center", Vector2.ZERO)
			cd_lbl.visible = true
		elif cd_lbl != null:
			cd_lbl.visible = false


func _spawn_enemy():
	if current_wave_index >= waves_data.size():
		return
	var current_wave = waves_data[current_wave_index]
	var enemy
	# Cek tong sampah dulu
	if enemy_pool.size() > 0:
		enemy = enemy_pool.pop_back()
	else:
		# Kalau tong sampah kosong, baru bikin baru
		enemy = Node2D.new()
		enemy.set_script(load("res://scenes/enemy.gd"))
		add_child(enemy)
		enemy.connect("enemy_reached_end", _on_enemy_reached_end.bind(enemy))
		enemy.connect("enemy_died", _on_enemy_died.bind(enemy))
	enemy.setup(enemy_path, current_wave["type"])
	active_enemies.append(enemy)
	enemies_spawned_in_wave += 1
	if enemies_spawned_in_wave >= current_wave["count"]:
		current_wave_index += 1
		enemies_spawned_in_wave = 0
		wave_timer = -5.0


func _on_enemy_reached_end(enemy: Node2D):
	crystal_hp -= 1
	_update_crystal_hud()
	active_enemies.erase(enemy)
	enemy_pool.append(enemy) # Masukkan ke tong sampah
	if crystal_hp <= 0 and not battle_over:
		_on_battle_lost()

func _on_enemy_died(enemy: Node2D):
	active_enemies.erase(enemy)
	enemy_pool.append(enemy) # Masukkan ke tong sampah


func _on_battle_won():
	battle_over = true
	_show_result_banner("VICTORY", Color(0.2, 0.9, 0.5))


func _on_battle_lost():
	battle_over = true
	_show_result_banner("DEFEAT", Color(0.9, 0.2, 0.2))


func _show_result_banner(text: String, color: Color):
	var bg = ColorRect.new()
	bg.size = Vector2(400, 90)
	bg.position = Vector2(440, 255)
	bg.color = Color(0, 0, 0, 0.82)
	add_child(bg)

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = Vector2(480, 262)
	add_child(lbl)


func _input(event):
	if battle_over:
		return

	if choosing_direction:
		if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			_try_pick_direction(get_global_mouse_position())
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_card_click(get_global_mouse_position())
		else:
			if dragging:
				_drop_spirit()

	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		_try_retreat()

	if event is InputEventMouseMotion and dragging and drag_sprite:
		drag_sprite.position = get_global_mouse_position()
		_update_drag_tint()


func _handle_card_click(mouse_pos: Vector2):
	for i in range(SPIRIT_ROSTER.size()):
		var data = SPIRIT_ROSTER[i]
		var sid: String = data["id"]

		if spirit_deployed.get(sid, false):
			continue
		if spirit_retreat_cooldown.get(sid, 0.0) > 0.0:
			continue
		if int(dp) < data["cost"]:
			continue

		var card_x := 20 + i * 110
		var card_y := grid_rows * TILE_SIZE + 8
		var rect := Rect2(card_x, card_y, 96, 84)
		if rect.has_point(mouse_pos):
			_start_drag(data)
			return


func _start_drag(data: Dictionary):
	dragging = true
	drag_spirit_id = data["id"]

	drag_sprite = Sprite2D.new()
	drag_sprite.scale = Vector2(0.35, 0.35)
	drag_sprite.position = get_global_mouse_position()
	drag_sprite.modulate = Color(1, 1, 1, 0.75)
	drag_sprite.z_index = 10

	var tex_path: String = data["texture"]
	if ResourceLoader.exists(tex_path):
		drag_sprite.texture = load(tex_path)

	add_child(drag_sprite)


func _drop_spirit():
	dragging = false
	var mouse_pos := get_global_mouse_position()
	var col := int(mouse_pos.x / TILE_SIZE)
	var row := int(mouse_pos.y / TILE_SIZE)
	var tile_key := "%d_%d" % [col, row]

	var spirit_data: Dictionary = {}
	for s in SPIRIT_ROSTER:
		if s["id"] == drag_spirit_id:
			spirit_data = s
			break

	if spirit_data.is_empty() or col < 0 or col >= grid_cols or row < 0 or row >= grid_rows:
		_cleanup_drag()
		return

	if (
		_can_deploy_at(col, row, spirit_data["unit_type"])
		and not occupied_tiles.has(tile_key)
		and int(dp) >= spirit_data["cost"]
	):
		pending_deploy_data = spirit_data
		pending_deploy_tile = Vector2i(col, row)
		_cleanup_drag()
		_enter_direction_mode()
		return

	_cleanup_drag()


func _enter_direction_mode():
	choosing_direction = true

	var tile_center := Vector2(
		pending_deploy_tile.x * TILE_SIZE + TILE_SIZE / 2.0,
		pending_deploy_tile.y * TILE_SIZE + TILE_SIZE / 2.0
	)

	var dirs := [
		["▲", Vector2(0, -TILE_SIZE * 0.7), Vector2i(0, -1)],
		["▼", Vector2(0, TILE_SIZE * 0.7), Vector2i(0, 1)],
		["◀", Vector2(-TILE_SIZE * 0.7, 0), Vector2i(-1, 0)],
		["▶", Vector2(TILE_SIZE * 0.7, 0), Vector2i(1, 0)],
	]

	for d in dirs:
		var btn := _make_direction_button(d[0], tile_center + d[1], d[2])
		add_child(btn)
		direction_buttons.append(btn)


func _make_direction_button(label_text: String, pos: Vector2, dir: Vector2i) -> Node2D:
	var btn := Node2D.new()
	btn.position = pos
	btn.z_index = 20

	var bg := ColorRect.new()
	bg.size = Vector2(40, 40)
	bg.position = Vector2(-20, -20)
	bg.color = Color(0.15, 0.55, 0.95, 0.88)
	btn.add_child(bg)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.position = Vector2(-9, -16)
	btn.add_child(lbl)

	btn.set_meta("facing_dir", dir)
	return btn


func _exit_direction_mode():
	choosing_direction = false
	pending_deploy_data = {}
	pending_deploy_tile = Vector2i.ZERO
	for btn in direction_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	direction_buttons.clear()


func _try_pick_direction(mouse_pos: Vector2) -> bool:
	for btn in direction_buttons:
		if not is_instance_valid(btn):
			continue
		var rect := Rect2(btn.position - Vector2(20, 20), Vector2(40, 40))
		if rect.has_point(mouse_pos):
			var dir: Vector2i = btn.get_meta("facing_dir")
			_confirm_deploy_direction(dir)
			return true
	_exit_direction_mode()
	return true


func _confirm_deploy_direction(dir: Vector2i):
	var spirit_data := pending_deploy_data
	var col := pending_deploy_tile.x
	var row := pending_deploy_tile.y
	var tile_key := "%d_%d" % [col, row]
	var sid: String = spirit_data["id"]

	_exit_direction_mode()

	if spirit_data.is_empty() or occupied_tiles.has(tile_key) or int(dp) < spirit_data["cost"]:
		return

	dp -= float(spirit_data["cost"])
	_update_dp_hud()

	spirit_deployed[sid] = true

	var spirit = Node2D.new()
	var script = load("res://scenes/spirit.gd")
	spirit.set_script(script)
	spirit.position = Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, row * TILE_SIZE + TILE_SIZE / 2.0)
	add_child(spirit)
	spirit.init(self, spirit_data)
	spirit.set_facing(dir)

	spirit.set_meta("spirit_id", sid)
	spirit.set_meta("tile_key", tile_key)
	spirit.connect("spirit_died", _on_spirit_died.bind(spirit))

	occupied_tiles[tile_key] = spirit
	deployed_spirits.append(spirit)


func _cleanup_drag():
	_reset_all_tile_highlights()
	if drag_sprite:
		drag_sprite.queue_free()
		drag_sprite = null
	drag_spirit_id = ""


func _on_spirit_died(spirit: Node2D):
	var sid: String = spirit.get_meta("spirit_id", "")
	var tile_key: String = spirit.get_meta("tile_key", "")

	if sid != "":
		spirit_deployed[sid] = false
		spirit_retreat_cooldown[sid] = RETREAT_COOLDOWN_SEC

	if tile_key != "" and occupied_tiles.has(tile_key):
		occupied_tiles.erase(tile_key)


func _try_retreat():
	var mouse_pos := get_global_mouse_position()
	var col := int(mouse_pos.x / TILE_SIZE)
	var row := int(mouse_pos.y / TILE_SIZE)
	var tile_key := "%d_%d" % [col, row]

	if not occupied_tiles.has(tile_key):
		return

	var spirit = occupied_tiles[tile_key]
	if not is_instance_valid(spirit):
		occupied_tiles.erase(tile_key)
		return

	var sid: String = spirit.get_meta("spirit_id", "")
	if sid != "":
		spirit_deployed[sid] = false
		spirit_retreat_cooldown[sid] = RETREAT_COOLDOWN_SEC

	if "blocking" in spirit:
		for enemy in spirit.blocking:
			if is_instance_valid(enemy):
				enemy.clear_blocked()

	spirit.queue_free()
	occupied_tiles.erase(tile_key)


func _update_drag_tint():
	if drag_spirit_id == "" or drag_sprite == null:
		return

	var spirit_data: Dictionary = {}
	for s in SPIRIT_ROSTER:
		if s["id"] == drag_spirit_id:
			spirit_data = s
			break

	var mouse_pos := get_global_mouse_position()
	var col := int(mouse_pos.x / TILE_SIZE)
	var row := int(mouse_pos.y / TILE_SIZE)
	var tile_key := "%d_%d" % [col, row]

	if _last_highlighted_tile != "" and _last_highlighted_tile != tile_key:
		_reset_tile_color(_last_highlighted_tile)

	var valid := (
		_can_deploy_at(col, row, spirit_data.get("unit_type", "melee"))
		and not occupied_tiles.has(tile_key)
	)

	drag_sprite.modulate = Color(1, 1, 1, 0.85) if valid else Color(1, 0.35, 0.35, 0.78)

	if tile_key in tile_nodes and is_instance_valid(tile_nodes[tile_key]):
		var tile_rect: ColorRect = tile_nodes[tile_key]
		if valid:
			tile_rect.color = Color(0.5, 1.0, 0.5, 0.85)
		else:
			tile_rect.color = Color(1.0, 0.3, 0.3, 0.70)
		_last_highlighted_tile = tile_key


func _reset_tile_color(tile_key: String):
	if tile_key == "" or tile_key not in tile_nodes:
		return
	if not is_instance_valid(tile_nodes[tile_key]):
		return
	var parts := tile_key.split("_")
	var c := int(parts[0])
	var r := int(parts[1])
	if r >= 0 and r < grid_rows and c >= 0 and c < grid_cols:
		var tile_type: TileType = map_layout[r][c]
		tile_nodes[tile_key].color = TILE_COLORS[tile_type]


func _reset_all_tile_highlights():
	_reset_tile_color(_last_highlighted_tile)
	_last_highlighted_tile = ""


func _can_deploy_at(col: int, row: int, unit_type: String) -> bool:
	if col < 0 or col >= grid_cols or row < 0 or row >= grid_rows:
		return false
	var tile_type: TileType = map_layout[row][col]
	match unit_type:
		"melee":
			return tile_type == TileType.GROUND
		"ranged":
			return tile_type == TileType.HIGH
	return false