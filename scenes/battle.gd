extends Node2D

# ============================================================
# 1. ENUM
# ============================================================
enum TileType {PATH, GROUND, HIGH, BLOCKED}

# ============================================================
# 2. CONSTANTS
# ============================================================
const TILE_SIZE := 128
const RETREAT_COOLDOWN_SEC := 8.0
const COVENANT_LINK_DURATION := 10.0
const WAVE_BREAK_SEC := 5.0

const TILE_COLORS := {
	TileType.PATH: Color(0.45, 0.28, 0.18, 0.85),
	TileType.GROUND: Color(0.18, 0.28, 0.38, 0.70),
	TileType.HIGH: Color(0.28, 0.40, 0.52, 0.80),
	TileType.BLOCKED: Color(0.08, 0.08, 0.10, 0.95),
}

const ELEMENT_COLORS := {
	"Umbra": Color(0.55, 0.18, 0.65),
	"Flare": Color(1.0, 0.68, 0.15),
	"Tide": Color(0.15, 0.48, 0.92),
	"Rime": Color(0.82, 0.92, 1.0),
	"Veil": Color(0.22, 0.85, 0.65),
}

# ============================================================
# 3. EXPORTED VARIABLES
# ============================================================
@export var spirit_roster: Array[SpiritData] = []
@export var enemy_roster: Array[EnemyData] = []
@export var stage_config_path: String = "res://data/chapter/1/stage_01.tres"

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
var max_enemies: int = 9

var cp_max: int = 99
var cp_regen_rate: float = 1.0
var cp_start: int = 10

var occupied_tiles: Dictionary = {}
var deployed_spirits: Array = []
var spirit_deployed: Dictionary = {}
var spirit_retreat_cooldown: Dictionary = {}

var tile_nodes: Dictionary = {}
var cp: float = 0.0
var cp_frozen: bool = false
var cp_label: Label = null
var cp_bar_fill: ColorRect = null
var crystal_hp: int = 0
var crystal_hp_label: Label = null

var wave_timer: float = 0.0
var waiting_next_wave: bool = false
var active_enemies: Array = []
var enemy_pool: Array = []
var projectile_pool: Array = []
var battle_over := false
var waves_data: Array = []
var current_wave_index: int = 0
var enemies_spawned_in_wave: int = 0
var wave_label: Label = null

var covenant_link_used: bool = false
var covenant_link_active: bool = false
var covenant_link_timer: float = 0.0
var revived_by_link_ids: Dictionary = {}
var covenant_overlay: ColorRect = null
var covenant_banner_label: Label = null

var dragging := false
var drag_spirit_id := ""
var drag_sprite: Sprite2D = null
var card_nodes: Dictionary = {}

var choosing_direction := false
var pending_deploy_data: SpiritData = null
var pending_deploy_tile: Vector2i = Vector2i.ZERO
var direction_buttons: Array = []

var _last_highlighted_tile: String = ""


# ============================================================
# 5. FUNCTIONS
# ============================================================
func _ready():
	_load_stage_config()

	if not _validate_all_data():
		battle_over = true
		return

	for s in spirit_roster:
		spirit_deployed[s.id] = false

	_draw_grid()
	_create_bottom_panel()
	_create_hud()
	_create_covenant_link_ui()


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
		max_enemies = 3
		cp_max = 99
		cp_regen_rate = 1.0
		cp_start = 10
		waves_data = [ {"type": "grunt", "count": 3}]
	else:
		grid_cols = stage.grid_cols
		grid_rows = stage.grid_rows
		map_layout = stage.map_layout
		enemy_path = stage.enemy_path
		crystal_max_hp = stage.crystal_max_hp
		spawn_interval = stage.spawn_interval
		max_enemies = stage.max_enemies
		cp_max = stage.cp_max
		cp_regen_rate = stage.cp_regen_rate
		cp_start = stage.cp_start
		if stage.waves.is_empty():
			waves_data = [
				{"type": "grunt", "count": 3},
				{"type": "sprinter", "count": 4},
				{"type": "brute", "count": 2}
			]
		else:
			waves_data = stage.waves

	cp = float(cp_start)
	crystal_hp = crystal_max_hp


# ============================================================
# TEMBOK PERTAHANAN (Validasi Data Sebelum Game Jalan)
# ============================================================
func _validate_all_data() -> bool:
	var is_valid := true
	var error_messages := []

	if stage == null and waves_data.is_empty():
		error_messages.append("- File StageConfig gagal dimuat / data kosong.")
	elif waves_data.is_empty():
		error_messages.append("- Data 'waves' di stage kosong! Game tidak bisa jalan.")
	elif max_enemies <= 0:
		error_messages.append("- Nilai max_enemies stage harus > 0.")

	if spirit_roster.is_empty():
		error_messages.append("- Spirit Roster kosong! Lupa masukkan file .tres ke Inspector?")
	else:
		for s in spirit_roster:
			if s.id == "" or s.hp <= 0:
				error_messages.append("- Spirit '%s' punya ID kosong atau HP <= 0." % s.id)

	if enemy_roster.is_empty():
		error_messages.append("- Enemy Roster kosong!")
	else:
		for e in enemy_roster:
			if e.id == "" or e.hp <= 0:
				error_messages.append("- Musuh '%s' punya ID kosong atau HP <= 0." % e.id)

	if not error_messages.is_empty():
		is_valid = false
		push_error("=== TEMBOK VALIDASI JEBOL ===")
		for msg in error_messages:
			push_error(msg)

		var err_lbl := Label.new()
		err_lbl.text = "ERROR DATA:\n" + "\n".join(error_messages)
		err_lbl.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		err_lbl.add_theme_font_size_override("font_size", 20)
		err_lbl.position = Vector2(100, 100)
		add_child(err_lbl)

	return is_valid


# ============================================================
# RENDER GRID & UI
# ============================================================
func _draw_grid():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var tile_type: TileType = map_layout[row][col]
			var tile := ColorRect.new()
			tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			tile.position = Vector2(col * TILE_SIZE + 1, row * TILE_SIZE + 1)
			tile.color = TILE_COLORS[tile_type]
			add_child(tile)
			tile_nodes["%d_%d" % [col, row]] = tile

			if tile_type == TileType.HIGH:
				var lbl := Label.new()
				lbl.text = "▲"
				lbl.add_theme_font_size_override("font_size", 11)
				lbl.position = Vector2(col * TILE_SIZE + 4, row * TILE_SIZE + 4)
				add_child(lbl)


func _create_bottom_panel():
	var panel_y := grid_rows * TILE_SIZE

	var bg := ColorRect.new()
	bg.size = Vector2(1280, 80)
	bg.position = Vector2(0, panel_y)
	bg.color = Color(0.06, 0.06, 0.10, 0.96)
	add_child(bg)

	var border := ColorRect.new()
	border.size = Vector2(1280, 2)
	border.position = Vector2(0, panel_y)
	border.color = Color(0.35, 0.55, 0.75, 0.7)
	add_child(border)

	for i in range(spirit_roster.size()):
		var data := spirit_roster[i]
		_create_spirit_card(data, i, panel_y)


func _create_spirit_card(data: SpiritData, index: int, panel_y: int):
	var card_x := 20 + index * 110
	var card_y := panel_y + 5

	var card := Node2D.new()
	card.name = "Card_" + data.id
	add_child(card)
	card_nodes[data.id] = card
	card.set_meta("card_center", Vector2(card_x + 34, card_y + 24))

	var card_bg := ColorRect.new()
	card_bg.size = Vector2(96, 70)
	card_bg.position = Vector2(card_x, card_y)
	card_bg.color = Color(0.12, 0.16, 0.22, 0.95)
	card.add_child(card_bg)

	var elem_color: Color = ELEMENT_COLORS.get(data.element, Color(0.7, 0.7, 0.8))

	var card_border := ColorRect.new()
	card_border.size = Vector2(96, 3)
	card_border.position = Vector2(card_x, card_y)
	card_border.color = elem_color
	card.add_child(card_border)

	var tex_path: String = data.texture_path
	if ResourceLoader.exists(tex_path):
		var icon := Sprite2D.new()
		icon.texture = load(tex_path)
		icon.scale = Vector2(0.22, 0.22)
		icon.position = Vector2(card_x + 48, card_y + 34)
		card.add_child(icon)
	else:
		var placeholder := ColorRect.new()
		placeholder.size = Vector2(54, 34)
		placeholder.position = Vector2(card_x + 21, card_y + 18)
		placeholder.color = elem_color * Color(0.55, 0.55, 0.55, 0.9)
		card.add_child(placeholder)

	var name_lbl := Label.new()
	name_lbl.text = data.display_name
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.position = Vector2(card_x + 4, card_y + 52)
	card.add_child(name_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "CP %d" % data.cp_cost
	cost_lbl.add_theme_font_size_override("font_size", 10)
	cost_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 0.5))
	cost_lbl.position = Vector2(card_x + 4, card_y + 4)
	card.add_child(cost_lbl)

	var type_lbl := Label.new()
	var unit_short := "M" if data.unit_type == "melee" else "R"
	type_lbl.text = "%s-%s" % [data.main_class.substr(0, 3).to_upper(), unit_short]
	type_lbl.add_theme_font_size_override("font_size", 9)
	type_lbl.add_theme_color_override("font_color", elem_color)
	type_lbl.position = Vector2(card_x + 56, card_y + 4)
	card.add_child(type_lbl)


func _create_hud():
	var hud_bg := ColorRect.new()
	hud_bg.size = Vector2(240, 36)
	hud_bg.position = Vector2(8, 8)
	hud_bg.color = Color(0, 0, 0, 0.55)
	add_child(hud_bg)

	crystal_hp_label = Label.new()
	crystal_hp_label.text = _crystal_text()
	crystal_hp_label.add_theme_font_size_override("font_size", 15)
	crystal_hp_label.position = Vector2(14, 12)
	add_child(crystal_hp_label)
	_update_crystal_hud()

	var cp_bg := ColorRect.new()
	cp_bg.size = Vector2(240, 36)
	cp_bg.position = Vector2(8, 50)
	cp_bg.color = Color(0, 0, 0, 0.55)
	add_child(cp_bg)

	var cp_track := ColorRect.new()
	cp_track.size = Vector2(150, 10)
	cp_track.position = Vector2(14, 68)
	cp_track.color = Color(0.2, 0.2, 0.2)
	add_child(cp_track)

	cp_bar_fill = ColorRect.new()
	cp_bar_fill.size = Vector2(0, 10)
	cp_bar_fill.position = Vector2(14, 68)
	cp_bar_fill.color = Color(0.5, 0.85, 1.0)
	add_child(cp_bar_fill)

	cp_label = Label.new()
	cp_label.text = "CP: %d / %d" % [int(cp), cp_max]
	cp_label.add_theme_font_size_override("font_size", 13)
	cp_label.position = Vector2(170, 60)
	add_child(cp_label)

	wave_label = Label.new()
	wave_label.text = "Wave: 1 / %d" % waves_data.size()
	wave_label.add_theme_font_size_override("font_size", 16)
	wave_label.position = Vector2(1070, 12)
	add_child(wave_label)


func _create_covenant_link_ui():
	covenant_overlay = ColorRect.new()
	covenant_overlay.size = Vector2(1280, 720)
	covenant_overlay.position = Vector2.ZERO
	covenant_overlay.color = Color(0.32, 0.20, 0.65, 0.16)
	covenant_overlay.z_index = 15
	covenant_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	covenant_overlay.visible = false
	add_child(covenant_overlay)

	covenant_banner_label = Label.new()
	covenant_banner_label.text = ""
	covenant_banner_label.add_theme_font_size_override("font_size", 18)
	covenant_banner_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	covenant_banner_label.position = Vector2(450, 12)
	covenant_banner_label.z_index = 20
	covenant_banner_label.visible = false
	add_child(covenant_banner_label)


func _crystal_text() -> String:
	return "💎 Crystal: %d / %d" % [crystal_hp, crystal_max_hp]


func _update_crystal_hud():
	if not crystal_hp_label:
		return
	crystal_hp_label.text = _crystal_text()
	var ratio := float(crystal_hp) / float(maxi(1, crystal_max_hp))
	if ratio <= 0.3:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	elif ratio <= 0.6:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	else:
		crystal_hp_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.9))


func _update_cp_hud():
	if cp_label:
		if cp_frozen:
			cp_label.text = "CP: %d (BEKU)" % int(cp)
			cp_label.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
		else:
			cp_label.text = "CP: %d / %d" % [int(cp), cp_max]
			cp_label.add_theme_color_override("font_color", Color(1, 1, 1))
	if cp_bar_fill:
		cp_bar_fill.size.x = 150.0 * (cp / float(maxi(1, cp_max)))
		cp_bar_fill.color = Color(0.75, 0.95, 1.0) if cp_frozen else Color(0.5, 0.85, 1.0)


func add_cp(amount: int):
	if cp_frozen or battle_over:
		return
	cp = minf(cp + float(amount), float(cp_max))
	_update_cp_hud()


# ============================================================
# OBJECT POOLING PROYEKTIL (Dipanggil Spirit Ranged)
# ============================================================
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


# ============================================================
# GAME LOOP
# ============================================================
func _process(delta):
	if battle_over:
		return

	if not cp_frozen:
		cp = minf(cp + cp_regen_rate * delta, float(cp_max))
	_update_cp_hud()
	_refresh_card_availability()

	if covenant_link_active:
		covenant_link_timer -= delta
		if covenant_banner_label:
			covenant_banner_label.text = "⚡ COVENANT LINK! %.1fs | CP BEKU" % maxf(0.0, covenant_link_timer)
		if covenant_link_timer <= 0.0:
			_end_covenant_link()

	# Spawn enemy & jeda antar wave
	if current_wave_index < waves_data.size():
		wave_timer += delta
		if waiting_next_wave:
			if wave_timer >= WAVE_BREAK_SEC:
				waiting_next_wave = false
				wave_timer = 0.0
				current_wave_index += 1
				enemies_spawned_in_wave = 0
				if current_wave_index < waves_data.size():
					_spawn_enemy()
		else:
			if wave_timer >= spawn_interval:
				wave_timer = 0.0
				_spawn_enemy()

	if wave_label:
		var total_waves := waves_data.size()
		var display_wave := mini(current_wave_index + 1, total_waves)
		if waiting_next_wave:
			var remain := ceili(maxf(0.0, WAVE_BREAK_SEC - wave_timer))
			wave_label.text = "Wave: %d / %d (Next: %ds)" % [display_wave, total_waves, remain]
		else:
			wave_label.text = "Wave: %d / %d" % [display_wave, total_waves]

	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))
	deployed_spirits = deployed_spirits.filter(func(s): return is_instance_valid(s))

	for sid in spirit_retreat_cooldown.keys():
		spirit_retreat_cooldown[sid] = maxf(0.0, spirit_retreat_cooldown[sid] - delta)

	if current_wave_index >= waves_data.size() and active_enemies.is_empty() and not battle_over:
		_on_battle_won()


func _refresh_card_availability():
	for data in spirit_roster:
		var sid: String = data.id
		var card = card_nodes.get(sid)
		if card == null:
			continue
		var can_afford: bool = int(cp) >= data.cp_cost
		var is_deployed: bool = spirit_deployed.get(sid, false)
		var cooldown: float = spirit_retreat_cooldown.get(sid, 0.0)
		var is_ready: bool = can_afford and not is_deployed and cooldown <= 0.0

		card.modulate = Color(1, 1, 1, 1) if is_ready else Color(0.4, 0.4, 0.4, 0.7)

		var cd_lbl: Label = card.get_node_or_null("CooldownLabel")
		if cooldown > 0.0:
			if cd_lbl == null:
				cd_lbl = Label.new()
				cd_lbl.name = "CooldownLabel"
				cd_lbl.add_theme_font_size_override("font_size", 16)
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
	var current_wave: Dictionary = waves_data[current_wave_index]

	var enemy_data: EnemyData = null
	for e in enemy_roster:
		if e.id == str(current_wave["type"]):
			enemy_data = e
			break

	enemies_spawned_in_wave += 1
	if enemy_data == null:
		push_error("ERROR: Musuh dengan ID '%s' tidak ditemukan di roster!" % str(current_wave["type"]))
	else:
		var enemy: Node2D
		if enemy_pool.size() > 0:
			enemy = enemy_pool.pop_back()
		else:
			enemy = Node2D.new()
			enemy.set_script(load("res://scenes/enemy.gd"))
			add_child(enemy)
			enemy.connect("enemy_reached_end", _on_enemy_reached_end.bind(enemy))
			enemy.connect("enemy_died", _on_enemy_died.bind(enemy))

		enemy.setup(enemy_path, enemy_data)
		active_enemies.append(enemy)

	if enemies_spawned_in_wave >= int(current_wave["count"]):
		if current_wave_index + 1 >= waves_data.size():
			current_wave_index = waves_data.size()
		else:
			waiting_next_wave = true
			wave_timer = 0.0


# ============================================================
# COVENANT LINK (LAST STAND) & SIGNAL HANDLERS
# ============================================================
func _activate_covenant_link(breaching_enemy: Node2D):
	covenant_link_used = true
	covenant_link_active = true
	covenant_link_timer = COVENANT_LINK_DURATION
	cp_frozen = true

	var knockback_tiles := 5 if breaching_enemy.tier == "boss" else 3
	breaching_enemy.push_back_tiles(knockback_tiles)

	for sid in spirit_retreat_cooldown.keys():
		if spirit_retreat_cooldown[sid] > 0.0:
			revived_by_link_ids[sid] = true
			spirit_retreat_cooldown[sid] = 0.0

	for s in deployed_spirits:
		if is_instance_valid(s):
			s.apply_covenant_link_buff(false)

	if covenant_overlay:
		covenant_overlay.visible = true
	if covenant_banner_label:
		covenant_banner_label.visible = true
		covenant_banner_label.text = "⚡ COVENANT LINK! %.1fs | CP BEKU" % covenant_link_timer

	_update_cp_hud()
	_refresh_card_availability()


func _end_covenant_link():
	covenant_link_active = false
	cp_frozen = false
	revived_by_link_ids.clear()

	if covenant_overlay:
		covenant_overlay.visible = false
	if covenant_banner_label:
		covenant_banner_label.visible = false

	for s in deployed_spirits:
		if is_instance_valid(s):
			s.end_covenant_link_buff()

	_update_cp_hud()


func _on_enemy_reached_end(enemy: Node2D):
	if not covenant_link_used:
		_activate_covenant_link(enemy)
		return

	crystal_hp -= 1
	_update_crystal_hud()
	enemy.deactivate_to_pool()
	active_enemies.erase(enemy)
	if not enemy_pool.has(enemy):
		enemy_pool.append(enemy)
	if crystal_hp <= 0 and not battle_over:
		_on_battle_lost()


func _on_enemy_died(enemy: Node2D):
	active_enemies.erase(enemy)
	if not enemy_pool.has(enemy):
		enemy_pool.append(enemy)


func _on_battle_won():
	battle_over = true
	var stars := 1
	if crystal_hp == crystal_max_hp:
		stars = 3
	elif crystal_hp > int(crystal_max_hp * 0.5):
		stars = 2
	_show_result_banner("VICTORY ★%d" % stars, Color(0.2, 0.9, 0.5))


func _on_battle_lost():
	battle_over = true
	_show_result_banner("DEFEAT", Color(0.9, 0.2, 0.2))


func _show_result_banner(text: String, color: Color):
	var bg := ColorRect.new()
	bg.size = Vector2(440, 90)
	bg.position = Vector2(420, 255)
	bg.color = Color(0, 0, 0, 0.82)
	add_child(bg)

	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 48)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = Vector2(455, 266)
	add_child(lbl)


# ============================================================
# INPUT (DRAG & DROP)
# ============================================================
func _input(event):
	if battle_over:
		return

	if choosing_direction:
		if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			get_viewport().set_input_as_handled()
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
	for i in range(spirit_roster.size()):
		var data := spirit_roster[i]
		var sid: String = data.id

		if spirit_deployed.get(sid, false):
			continue
		if spirit_retreat_cooldown.get(sid, 0.0) > 0.0:
			continue
		if int(cp) < data.cp_cost:
			continue

		var card_x := 20 + i * 110
		var card_y := grid_rows * TILE_SIZE + 5
		var rect := Rect2(card_x, card_y, 96, 70)
		if rect.has_point(mouse_pos):
			_start_drag(data)
			return


func _start_drag(data: SpiritData):
	dragging = true
	drag_spirit_id = data.id

	drag_sprite = Sprite2D.new()
	drag_sprite.scale = Vector2(0.35, 0.35)
	drag_sprite.position = get_global_mouse_position()
	drag_sprite.modulate = Color(1, 1, 1, 0.75)
	drag_sprite.z_index = 10

	var tex_path: String = data.texture_path
	if ResourceLoader.exists(tex_path):
		drag_sprite.texture = load(tex_path)

	add_child(drag_sprite)


func _drop_spirit():
	dragging = false
	var mouse_pos := get_global_mouse_position()
	var col := floori(mouse_pos.x / TILE_SIZE)
	var row := floori(mouse_pos.y / TILE_SIZE)
	var tile_key := "%d_%d" % [col, row]

	var spirit_data: SpiritData = null
	for s in spirit_roster:
		if s.id == drag_spirit_id:
			spirit_data = s
			break

	if spirit_data == null or col < 0 or col >= grid_cols or row < 0 or row >= grid_rows:
		_cleanup_drag()
		return

	if (
		_can_deploy_at(col, row, spirit_data.unit_type)
		and not occupied_tiles.has(tile_key)
		and int(cp) >= spirit_data.cp_cost
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
	pending_deploy_data = null
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

	_exit_direction_mode()

	if spirit_data == null or occupied_tiles.has(tile_key) or int(cp) < spirit_data.cp_cost:
		return

	var sid: String = spirit_data.id
	cp -= float(spirit_data.cp_cost)
	_update_cp_hud()

	spirit_deployed[sid] = true

	var spirit := Node2D.new()
	var script: Script = load("res://scenes/spirit.gd")
	spirit.set_script(script)
	spirit.position = Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, row * TILE_SIZE + TILE_SIZE / 2.0)
	add_child(spirit)
	spirit.init(self, spirit_data)
	spirit.set_facing(dir)

	if covenant_link_active:
		var was_revived: bool = revived_by_link_ids.get(sid, false)
		spirit.apply_covenant_link_buff(was_revived)
		revived_by_link_ids.erase(sid)

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
	var col := floori(mouse_pos.x / TILE_SIZE)
	var row := floori(mouse_pos.y / TILE_SIZE)
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

	var spirit_data: SpiritData = null
	for s in spirit_roster:
		if s.id == drag_spirit_id:
			spirit_data = s
			break

	if spirit_data == null:
		return

	var mouse_pos := get_global_mouse_position()
	var col := floori(mouse_pos.x / TILE_SIZE)
	var row := floori(mouse_pos.y / TILE_SIZE)
	var tile_key := "%d_%d" % [col, row]

	if _last_highlighted_tile != "" and _last_highlighted_tile != tile_key:
		_reset_tile_color(_last_highlighted_tile)

	var valid := (
		_can_deploy_at(col, row, spirit_data.unit_type) and not occupied_tiles.has(tile_key)
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