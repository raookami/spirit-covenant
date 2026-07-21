extends Node2D

# ============================================================
# STAGE CONFIG — path ke .tres yang mau dimainkan
# Ganti path ini (atau set dari luar sebelum scene masuk tree)
# untuk pilih stage lain, tanpa sentuh kode di bawah.
# ============================================================
@export var stage_config_path: String = "res://data/stage_01.tres"
var stage: StageConfig

# ============================================================
# GRID & MAP — diisi dari StageConfig saat _ready(), bukan lagi
# hardcode. TILE_SIZE tetap const karena itu properti visual/engine,
# bukan data per-stage.
# ============================================================
const TILE_SIZE := 128

enum TileType { PATH, GROUND, HIGH, BLOCKED }

var GRID_COLS: int = 10
var GRID_ROWS: int = 5
var MAP_LAYOUT: Array = []
var ENEMY_PATH: Array = []

const TILE_COLORS = {
	TileType.PATH:    Color(0.45, 0.28, 0.18, 0.85),
	TileType.GROUND:  Color(0.18, 0.28, 0.38, 0.70),
	TileType.HIGH:    Color(0.28, 0.40, 0.52, 0.80),
	TileType.BLOCKED: Color(0.08, 0.08, 0.10, 0.95),
}

# ============================================================
# GAMEPLAY — juga dari StageConfig, sebelumnya const hardcode
# ============================================================
var CRYSTAL_MAX_HP: int   = 10
var SPAWN_INTERVAL: float = 3.0
var MAX_ENEMIES: int      = 8

# DP (Deploy Point) — kayak Arknights
var DP_MAX: int          = 99
var DP_REGEN_RATE: float = 1.0   # DP per detik
var DP_START: int        = 10

# ============================================================
# DATA ROSTER SPIRIT
# Tambah entry di sini untuk spirit baru.
# unit_type: "melee" → deploy di PATH | "ranged" → deploy di HIGH
# block: jumlah musuh yang bisa ditahan sekaligus (ranged = 0)
# ============================================================
const SPIRIT_ROSTER = [
	{
		"id":        "raookami",
		"name":      "Raoo",
		"unit_type": "melee",
		"cost":      8,
		"block":     1,
		"atk":       1,
		"atk_range": 1.2,   # tile
		"atk_spd":   1.5,   # detik per serangan
		"texture":   "res://assets/spirites/characters/raookami/raookami.png",
	},
	{
		"id":        "kuma",
		"name":      "Kuma",
		"unit_type": "melee",
		"cost":      12,
		"block":     3,
		"atk":       1,
		"atk_range": 1.0,
		"atk_spd":   2.0,
		"texture":   "res://assets/spirites/characters/kuma/kuma.png",
	},
	{
		"id":        "yoshiki",
		"name":      "Shiki",
		"unit_type": "ranged",
		"cost":      10,
		"block":     0,
		"atk":       2,
		"atk_range": 3.5,
		"atk_spd":   1.2,
		"texture":   "res://assets/spirites/characters/yoshiki/yoshiki.png",
	},
	{
		"id":        "ratora",
		"name":      "Tora",
		"unit_type": "melee",
		"cost":      9,
		"block":     2,
		"atk":       2,
		"atk_range": 1.0,
		"atk_spd":   1.0,
		"texture":   "res://assets/spirites/characters/ratora/ratora.png",
	},
	{
		"id":        "koyuuki",
		"name":      "Yuki",
		"unit_type": "ranged",
		"cost":      11,
		"block":     0,
		"atk":       1,
		"atk_range": 4.0,
		"atk_spd":   2.0,
		"texture":   "res://assets/spirites/characters/koyuuki/koyuuki.png",
	},
]

# ============================================================
# STATE
# ============================================================
var occupied_tiles:   Dictionary = {}   # "col_row" → spirit node
var deployed_spirits: Array      = []   # semua spirit yang aktif di field

# State per spirit — apakah sudah ter-deploy
# key: spirit id (string) → bool
var spirit_deployed: Dictionary  = {}

# Referensi ColorRect tile untuk highlight saat drag
var tile_nodes: Dictionary = {}   # "col_row" → ColorRect

# DP
var dp: float = 0.0
var dp_label: Label = null
var dp_bar_fill: ColorRect = null

# Crystal
var crystal_hp: int = 0
var crystal_hp_label: Label = null

# Spawn
var wave_timer: float    = 0.0
var enemies_spawned: int = 0
var active_enemies: Array = []

var battle_over := false

# Drag state
var dragging        := false
var drag_spirit_id  := ""          # id spirit yang sedang di-drag
var drag_sprite: Sprite2D = null

# Referensi card node per spirit id — untuk show/hide
var card_nodes: Dictionary = {}    # spirit_id → Node (container card)

# ============================================================
# READY
# ============================================================
func _ready():
	_load_stage_config()

	# Init deployed state semua spirit = false
	for s in SPIRIT_ROSTER:
		spirit_deployed[s["id"]] = false

	_draw_grid()
	_create_bottom_panel()
	_create_hud()

# ============================================================
# LOAD STAGE CONFIG — dipanggil paling awal di _ready(), sebelum
# apapun lain pakai GRID_COLS/MAP_LAYOUT/dp/crystal_hp dsb.
# Kalau file config tidak ada/gagal load, fallback ke nilai default
# yang sebelumnya hardcode (stage 1 asli) supaya tidak silent-break.
# ============================================================
func _load_stage_config():
	if stage_config_path != "" and ResourceLoader.exists(stage_config_path):
		stage = load(stage_config_path)
	if stage == null:
		push_warning("StageConfig gagal di-load dari '%s' — pakai fallback default." % stage_config_path)
		GRID_COLS      = 10
		GRID_ROWS      = 5
		MAP_LAYOUT     = [
			[0, 0, 3, 0, 0, 0, 0, 3, 0, 0],
			[1, 1, 1, 0, 2, 2, 0, 3, 0, 0],
			[3, 3, 1, 0, 2, 2, 0, 1, 1, 1],
			[0, 0, 1, 0, 0, 0, 0, 1, 3, 0],
			[0, 0, 1, 1, 1, 1, 1, 1, 3, 0],
		]
		ENEMY_PATH     = [
			[0,1],[1,1],[2,1],[2,2],[2,3],[2,4],
			[3,4],[4,4],[5,4],[6,4],[7,4],[7,3],[7,2],
			[8,2],[9,2]
		]
		CRYSTAL_MAX_HP = 10
		SPAWN_INTERVAL = 3.0
		MAX_ENEMIES    = 8
		DP_MAX         = 99
		DP_REGEN_RATE  = 1.0
		DP_START       = 10
	else:
		GRID_COLS      = stage.grid_cols
		GRID_ROWS      = stage.grid_rows
		MAP_LAYOUT     = stage.map_layout
		ENEMY_PATH     = stage.enemy_path
		CRYSTAL_MAX_HP = stage.crystal_max_hp
		SPAWN_INTERVAL = stage.spawn_interval
		MAX_ENEMIES    = stage.max_enemies
		DP_MAX         = stage.dp_max
		DP_REGEN_RATE  = stage.dp_regen_rate
		DP_START       = stage.dp_start

	dp         = float(DP_START)
	crystal_hp = CRYSTAL_MAX_HP

# ============================================================
# RENDER GRID
# ============================================================
func _draw_grid():
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var tile_type: TileType = MAP_LAYOUT[row][col]
			var tile = ColorRect.new()
			tile.size     = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			tile.position = Vector2(col * TILE_SIZE + 1, row * TILE_SIZE + 1)
			tile.color    = TILE_COLORS[tile_type]
			add_child(tile)
			tile_nodes["%d_%d" % [col, row]] = tile

			# Indikator HIGH tile
			if tile_type == TileType.HIGH:
				var lbl = Label.new()
				lbl.text = "▲"
				lbl.add_theme_font_size_override("font_size", 11)
				lbl.position = Vector2(col * TILE_SIZE + 4, row * TILE_SIZE + 4)
				add_child(lbl)

# ============================================================
# BOTTOM PANEL — kartu spirit
# ============================================================
func _create_bottom_panel():
	var panel_y := GRID_ROWS * TILE_SIZE

	# Background panel
	var bg = ColorRect.new()
	bg.size     = Vector2(1280, 100)
	bg.position = Vector2(0, panel_y)
	bg.color    = Color(0.06, 0.06, 0.10, 0.96)
	add_child(bg)

	# Border atas
	var border = ColorRect.new()
	border.size     = Vector2(1280, 2)
	border.position = Vector2(0, panel_y)
	border.color    = Color(0.35, 0.55, 0.75, 0.7)
	add_child(border)

	# Buat card per spirit
	for i in range(SPIRIT_ROSTER.size()):
		var data = SPIRIT_ROSTER[i]
		_create_spirit_card(data, i, panel_y)

func _create_spirit_card(data: Dictionary, index: int, panel_y: int):
	var card_x := 20 + index * 110
	var card_y := panel_y + 8

	# Container — pakai Node2D sebagai parent card
	var card = Node2D.new()
	card.name = "Card_" + data["id"]
	add_child(card)
	card_nodes[data["id"]] = card

	# Background card
	var card_bg = ColorRect.new()
	card_bg.size     = Vector2(96, 84)
	card_bg.position = Vector2(card_x, card_y)
	card_bg.color    = Color(0.12, 0.16, 0.22, 0.95)
	card.add_child(card_bg)

	# Border card
	var card_border = ColorRect.new()
	card_border.size     = Vector2(96, 2)
	card_border.position = Vector2(card_x, card_y)
	# Melee = oranye, Ranged = biru
	card_border.color = Color(0.9, 0.5, 0.1) if data["unit_type"] == "melee" else Color(0.2, 0.6, 1.0)
	card.add_child(card_border)

	# Texture spirit — fallback ke placeholder kalau aset belum ada
	var tex_path: String = data["texture"]
	if ResourceLoader.exists(tex_path):
		var icon = Sprite2D.new()
		icon.texture  = load(tex_path)
		icon.scale    = Vector2(0.25, 0.25)
		icon.position = Vector2(card_x + 48, card_y + 36)
		card.add_child(icon)
	else:
		# Placeholder warna
		var placeholder = ColorRect.new()
		placeholder.size     = Vector2(60, 50)
		placeholder.position = Vector2(card_x + 18, card_y + 8)
		placeholder.color    = Color(0.2, 0.3, 0.4)
		card.add_child(placeholder)

	# Nama spirit
	var name_lbl = Label.new()
	name_lbl.text = data["name"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.position = Vector2(card_x + 4, card_y + 64)
	card.add_child(name_lbl)

	# Cost label
	var cost_lbl = Label.new()
	cost_lbl.text = "DP %d" % data["cost"]
	cost_lbl.add_theme_font_size_override("font_size", 10)
	cost_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 0.5))
	cost_lbl.position = Vector2(card_x + 4, card_y + 4)
	card.add_child(cost_lbl)

	# Type label kecil
	var type_lbl = Label.new()
	type_lbl.text = "M" if data["unit_type"] == "melee" else "R"
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override("font_color",
		Color(0.9, 0.5, 0.1) if data["unit_type"] == "melee" else Color(0.2, 0.6, 1.0))
	type_lbl.position = Vector2(card_x + 78, card_y + 4)
	card.add_child(type_lbl)

# ============================================================
# HUD — crystal HP + DP bar
# ============================================================
func _create_hud():
	# === Crystal HP ===
	var hud_bg = ColorRect.new()
	hud_bg.size     = Vector2(230, 36)
	hud_bg.position = Vector2(8, 8)
	hud_bg.color    = Color(0, 0, 0, 0.55)
	add_child(hud_bg)

	crystal_hp_label = Label.new()
	crystal_hp_label.text = _crystal_text()
	crystal_hp_label.add_theme_font_size_override("font_size", 15)
	crystal_hp_label.position = Vector2(14, 12)
	add_child(crystal_hp_label)

	# === DP Bar ===
	var dp_bg = ColorRect.new()
	dp_bg.size     = Vector2(230, 36)
	dp_bg.position = Vector2(8, 50)
	dp_bg.color    = Color(0, 0, 0, 0.55)
	add_child(dp_bg)

	# Track bar
	var dp_track = ColorRect.new()
	dp_track.size     = Vector2(160, 10)
	dp_track.position = Vector2(14, 68)
	dp_track.color    = Color(0.2, 0.2, 0.2)
	add_child(dp_track)

	# Fill bar
	dp_bar_fill = ColorRect.new()
	dp_bar_fill.size     = Vector2(0, 10)
	dp_bar_fill.position = Vector2(14, 68)
	dp_bar_fill.color    = Color(0.5, 0.85, 1.0)
	add_child(dp_bar_fill)

	# Label DP
	dp_label = Label.new()
	dp_label.text = "DP: %d / %d" % [int(dp), DP_MAX]
	dp_label.add_theme_font_size_override("font_size", 13)
	dp_label.position = Vector2(180, 60)
	add_child(dp_label)

func _crystal_text() -> String:
	return "💎 Crystal: %d / %d" % [crystal_hp, CRYSTAL_MAX_HP]

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
		dp_label.text = "DP: %d / %d" % [int(dp), DP_MAX]
	if dp_bar_fill:
		dp_bar_fill.size.x = 160.0 * (dp / float(DP_MAX))

# ============================================================
# GAME LOOP
# ============================================================
func _process(delta):
	if battle_over:
		return

	# Regen DP
	dp = minf(dp + DP_REGEN_RATE * delta, float(DP_MAX))
	_update_dp_hud()
	_refresh_card_availability()

	# Spawn enemy
	if enemies_spawned < MAX_ENEMIES:
		wave_timer += delta
		if wave_timer >= SPAWN_INTERVAL:
			wave_timer = 0.0
			_spawn_enemy()

	# Bersihkan node invalid
	active_enemies   = active_enemies.filter(func(e): return is_instance_valid(e))
	deployed_spirits = deployed_spirits.filter(func(s): return is_instance_valid(s))

	# Cek menang
	if enemies_spawned >= MAX_ENEMIES and active_enemies.is_empty():
		_on_battle_won()

# Tint card abu-abu kalau tidak mampu beli atau sudah deployed
func _refresh_card_availability():
	for data in SPIRIT_ROSTER:
		var sid: String = data["id"]
		var card = card_nodes.get(sid)
		if card == null:
			continue
		var can_afford: bool = int(dp) >= data["cost"]
		var is_deployed: bool = spirit_deployed.get(sid, false)
		# Gelap = tidak bisa/sudah deployed
		card.modulate = Color(1, 1, 1, 1) if (can_afford and not is_deployed) else Color(0.4, 0.4, 0.4, 0.7)

# ============================================================
# SPAWN ENEMY
# ============================================================
func _spawn_enemy():
	var enemy = Node2D.new()
	var script = load("res://scenes/enemy.gd")
	enemy.set_script(script)
	# PENTING: setup() dipanggil SEBELUM add_child().
	# add_child() langsung memicu _ready() di frame yang sama, dan _ready()
	# butuh `path` sudah terisi untuk memanggil _init_position(). Kalau
	# urutannya dibalik, _ready() jalan duluan dengan path kosong, dan
	# posisi awal enemy cuma ketolong secara kebetulan lewat flag _initialized
	# di setup() — rapuh dan gampang pecah kalau _ready() direfactor nanti.
	enemy.setup(ENEMY_PATH)
	add_child(enemy)
	enemy.connect("enemy_reached_end", _on_enemy_reached_end)
	enemy.connect("enemy_died", _on_enemy_died)
	active_enemies.append(enemy)
	enemies_spawned += 1

# ============================================================
# SIGNAL HANDLERS
# ============================================================
func _on_enemy_reached_end():
	crystal_hp -= 1
	_update_crystal_hud()
	if crystal_hp <= 0 and not battle_over:
		_on_battle_lost()

func _on_enemy_died():
	pass  # bisa tambah coin/reward di sini

func _on_battle_won():
	battle_over = true
	_show_result_banner("VICTORY", Color(0.2, 0.9, 0.5))

func _on_battle_lost():
	battle_over = true
	_show_result_banner("DEFEAT", Color(0.9, 0.2, 0.2))

func _show_result_banner(text: String, color: Color):
	var bg = ColorRect.new()
	bg.size     = Vector2(400, 90)
	bg.position = Vector2(440, 255)
	bg.color    = Color(0, 0, 0, 0.82)
	add_child(bg)

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = Vector2(480, 262)
	add_child(lbl)

# ============================================================
# INPUT
# ============================================================
func _input(event):
	if battle_over:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_card_click(get_global_mouse_position())
		else:
			if dragging:
				_drop_spirit()

	elif event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.pressed:
		_try_retreat()

	if event is InputEventMouseMotion and dragging and drag_sprite:
		drag_sprite.position = get_global_mouse_position()
		_update_drag_tint()

# Cek apakah klik mengenai salah satu card
func _handle_card_click(mouse_pos: Vector2):
	for i in range(SPIRIT_ROSTER.size()):
		var data = SPIRIT_ROSTER[i]
		var sid: String = data["id"]

		# Sudah deployed — tidak bisa di-drag lagi
		if spirit_deployed.get(sid, false):
			continue

		# Tidak mampu beli
		if int(dp) < data["cost"]:
			continue

		# Bounding box card
		var card_x := 20 + i * 110
		var card_y := GRID_ROWS * TILE_SIZE + 8
		var rect   := Rect2(card_x, card_y, 96, 84)
		if rect.has_point(mouse_pos):
			_start_drag(data)
			return

func _start_drag(data: Dictionary):
	dragging       = true
	drag_spirit_id = data["id"]

	drag_sprite          = Sprite2D.new()
	drag_sprite.scale    = Vector2(0.35, 0.35)
	drag_sprite.position = get_global_mouse_position()
	drag_sprite.modulate = Color(1, 1, 1, 0.75)
	drag_sprite.z_index  = 10

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

	# Cari data spirit yang di-drag
	var spirit_data: Dictionary = {}
	for s in SPIRIT_ROSTER:
		if s["id"] == drag_spirit_id:
			spirit_data = s
			break

	# Tidak ada data atau drop di luar grid → cancel
	if spirit_data.is_empty() or col < 0 or col >= GRID_COLS or row < 0 or row >= GRID_ROWS:
		_cleanup_drag()
		return

	# Validasi tile sesuai unit type
	if _can_deploy_at(col, row, spirit_data["unit_type"]) \
	and not occupied_tiles.has(tile_key) \
	and int(dp) >= spirit_data["cost"]:

		# Kurangi DP
		dp -= float(spirit_data["cost"])
		_update_dp_hud()

		# Tandai spirit sebagai deployed — card hilang dari panel
		spirit_deployed[drag_spirit_id] = true

		# Spawn spirit di field
		var spirit = Node2D.new()
		var script = load("res://scenes/spirit.gd")
		spirit.set_script(script)
		spirit.position = Vector2(
			col * TILE_SIZE + TILE_SIZE / 2,
			row * TILE_SIZE + TILE_SIZE / 2
		)
		add_child(spirit)
		spirit.init(self, spirit_data)

		# Simpan referensi spirit_id di node spirit untuk keperluan retreat
		spirit.set_meta("spirit_id", drag_spirit_id)

		occupied_tiles[tile_key]  = spirit
		deployed_spirits.append(spirit)

	_cleanup_drag()

func _cleanup_drag():
	_reset_all_tile_highlights()
	if drag_sprite:
		drag_sprite.queue_free()
		drag_sprite = null
	drag_spirit_id = ""

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

	# Kembalikan state spirit → card muncul lagi
	var sid: String = spirit.get_meta("spirit_id", "")
	if sid != "":
		spirit_deployed[sid] = false

	# Lepas semua musuh yang sedang di-block spirit ini SEBELUM spirit dihapus.
	# Tanpa ini, musuh baru lanjut jalan 1 frame kemudian (saat enemy.gd
	# mendeteksi blocked_by sudah invalid) — kecil, tapi kenapa nunggu
	# kalau kita punya referensinya sekarang.
	if "blocking" in spirit:
		for enemy in spirit.blocking:
			if is_instance_valid(enemy):
				enemy.clear_blocked()

	spirit.queue_free()
	occupied_tiles.erase(tile_key)

# ============================================================
# DRAG HIGHLIGHT — highlight tile valid, tint merah kalau tidak valid
# ============================================================
var _last_highlighted_tile: String = ""

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

	# Reset highlight tile sebelumnya
	if _last_highlighted_tile != "" and _last_highlighted_tile != tile_key:
		_reset_tile_color(_last_highlighted_tile)

	var valid := _can_deploy_at(col, row, spirit_data.get("unit_type", "melee")) \
				 and not occupied_tiles.has(tile_key)

	# Tint drag sprite
	drag_sprite.modulate = Color(1, 1, 1, 0.85) if valid else Color(1, 0.35, 0.35, 0.78)

	# Highlight tile di grid
	if tile_key in tile_nodes and is_instance_valid(tile_nodes[tile_key]):
		var tile_rect: ColorRect = tile_nodes[tile_key]
		if valid:
			tile_rect.color = Color(0.5, 1.0, 0.5, 0.85)   # hijau = bisa deploy
		else:
			tile_rect.color = Color(1.0, 0.3, 0.3, 0.70)   # merah = tidak bisa
		_last_highlighted_tile = tile_key

func _reset_tile_color(tile_key: String):
	if tile_key == "" or tile_key not in tile_nodes:
		return
	if not is_instance_valid(tile_nodes[tile_key]):
		return
	# Parse col, row dari key
	var parts := tile_key.split("_")
	var c := int(parts[0])
	var r := int(parts[1])
	if r >= 0 and r < GRID_ROWS and c >= 0 and c < GRID_COLS:
		var tile_type: TileType = MAP_LAYOUT[r][c]
		tile_nodes[tile_key].color = TILE_COLORS[tile_type]

func _reset_all_tile_highlights():
	_reset_tile_color(_last_highlighted_tile)
	_last_highlighted_tile = ""

# ============================================================
# VALIDASI DEPLOY PER UNIT TYPE
# melee  → hanya GROUND (berdiri di samping jalur PATH, grab musuh yang lewat)
# ranged → hanya HIGH   (elevated, serang dari kejauhan)
# ============================================================
func _can_deploy_at(col: int, row: int, unit_type: String) -> bool:
	if col < 0 or col >= GRID_COLS or row < 0 or row >= GRID_ROWS:
		return false
	var tile_type: TileType = MAP_LAYOUT[row][col]
	match unit_type:
		"melee":  return tile_type == TileType.GROUND   # biru — berdiri di samping jalur
		"ranged": return tile_type == TileType.HIGH      # biru terang — elevated
	return false

# ============================================================
# DIPANGGIL OLEH SPIRIT — cari musuh yang sedang di-block
# spirit melee mengisi slot block musuh, musuh berhenti
# ============================================================
func get_blocking_enemies(spirit_node: Node2D, block_count: int) -> Array:
	var result := []
	for enemy in active_enemies:
		if not is_instance_valid(enemy):
			continue
		# Musuh dianggap ter-block kalau posisinya sama tile dengan spirit
		var enemy_col := int(enemy.position.x / TILE_SIZE)
		var enemy_row := int(enemy.position.y / TILE_SIZE)
		var spirit_col := int(spirit_node.position.x / TILE_SIZE)
		var spirit_row := int(spirit_node.position.y / TILE_SIZE)
		if enemy_col == spirit_col and enemy_row == spirit_row:
			result.append(enemy)
			if result.size() >= block_count:
				break
	return result
