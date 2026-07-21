extends Node2D

# ============================================================
# STAT (diisi lewat init() dari data SPIRIT_ROSTER)
# ============================================================
var spirit_id:   String = ""
var unit_type:   String = "melee"   # "melee" | "ranged"
var atk:         int    = 1
var attack_range: float = 2.0       # dalam tile
var attack_cd:   float  = 1.5       # detik per serangan
var block_count: int    = 1         # max musuh yang bisa ditahan (melee)

var tile_size := 128

# ============================================================
# STATE RUNTIME
# ============================================================
var battle_ref: Node
var attack_timer: float = 0.0

# Daftar musuh yang sedang di-block oleh spirit ini (melee)
var blocking: Array = []

# ============================================================
# NODE REFERENSI
# ============================================================
var anim_sprite: AnimatedSprite2D
var live2d_model: Node2D       # GDCubismUserModel, kalau spirit ini punya model Live2D
var is_live2d := false
var range_circle: Node2D
var _range_visible := false

# ============================================================
# INIT — dipanggil dari battle.gd setelah add_child
# ============================================================
func init(battle: Node, data: Dictionary):
	battle_ref   = battle
	spirit_id    = data.get("id", "")
	unit_type    = data.get("unit_type", "melee")
	atk          = data.get("atk", 1)
	attack_range = data.get("atk_range", 2.0)
	attack_cd    = data.get("atk_spd", 1.5)
	block_count  = data.get("block", 1)
	_build_visuals()

func _ready():
	_build_range_indicator()

# ============================================================
# VISUAL
# ============================================================
func _build_visuals():
	# Prioritas 1: model Live2D — cek apakah file .model3.json ada
	var model_path = "res://assets/spirites/characters/%s/%s_idle.model3.json" % [spirit_id, spirit_id]
	if ResourceLoader.exists(model_path):
		_build_live2d_visual(model_path)
		return

	# Prioritas 2: sprite sheet PNG idle (sistem lama)
	anim_sprite = AnimatedSprite2D.new()

	var frames = SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 12)

	# Load frame animasi idle — fallback ke placeholder kalau belum ada
	var loaded_any := false
	for i in range(24):
		var path = "res://assets/spirites/characters/%s/%s_idle_%04d.png" % [spirit_id, spirit_id, i]
		if ResourceLoader.exists(path):
			frames.add_frame("idle", load(path))
			loaded_any = true

	if not loaded_any:
		# Placeholder: ColorRect berbeda warna per unit type
		var placeholder = ColorRect.new()
		placeholder.size     = Vector2(48, 48)
		placeholder.position = Vector2(-24, -36)
		placeholder.color    = Color(0.8, 0.5, 0.1) if unit_type == "melee" else Color(0.2, 0.5, 0.9)
		add_child(placeholder)
	else:
		anim_sprite.sprite_frames = frames
		anim_sprite.scale         = Vector2(0.6, 0.6)
		anim_sprite.z_index       = 1
		anim_sprite.play("idle")
		add_child(anim_sprite)

# ============================================================
# VISUAL — MODEL LIVE2D (GDCubism)
# ============================================================
func _build_live2d_visual(model_path: String):
	is_live2d = true

	live2d_model = ClassDB.instantiate("GDCubismUserModel")
	live2d_model.assets = model_path
	live2d_model.scale  = Vector2(0.1, 0.1)   # sesuaikan skala ke ukuran tile
	live2d_model.position = Vector2(0, -20)     # sesuaikan agar kaki menapak tile
	live2d_model.z_index = 1
	add_child(live2d_model)

	# PENTING: start_motion("Idle", 0, 1) di GDCubism SELALU memanggil
	# start_motion_loop(..., loop=false, ...) di balik layar — makanya motion
	# cuma main sekali lalu berhenti (tidak loop), walau di motion3.json-nya
	# sendiri sudah "Loop": true.
	#
	# Jadi kita panggil start_motion_loop() langsung dengan loop=true dan
	# loop_fade_in=true, supaya GDCubism yang urus looping-nya secara native
	# dengan fade mulus antar putaran — tidak perlu retrigger manual/timer
	# sama sekali, dan tidak ada jeda diam sebelum lanjut ke putaran berikutnya.
	live2d_model.start_motion_loop("Idle", 0, 1, true, true)

	# Label tipe kecil di atas sprite (debug — bisa hapus nanti)
	var type_lbl = Label.new()
	type_lbl.text = "M" if unit_type == "melee" else "R"
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override("font_color",
		Color(1.0, 0.6, 0.1) if unit_type == "melee" else Color(0.3, 0.7, 1.0))
	type_lbl.position = Vector2(-6, -52)
	add_child(type_lbl)

# ============================================================
# RANGE INDICATOR (lingkaran transparan)
# ============================================================
func _build_range_indicator():
	range_circle = Node2D.new()
	range_circle.z_index = -1
	range_circle.visible = false
	add_child(range_circle)

	# PENTING: untuk melee, radius block sebenarnya pakai BLOCK_RADIUS_TILES
	# (konstanta di bawah), BUKAN attack_range/atk_range dari roster —
	# dua nilai itu kebetulan sama untuk Raoo (1.2) tapi beda untuk Kuma/Ratora
	# (1.0). Kalau indikator pakai attack_range, lingkaran yang dilihat
	# pemain tidak match radius grab asli. Ranged tetap pakai attack_range
	# karena itu memang radius tembak sesungguhnya.
	var indicator_radius := BLOCK_RADIUS_TILES if unit_type == "melee" else attack_range

	var circle = _CircleDrawer.new()
	circle.radius      = indicator_radius * tile_size
	circle.fill_color  = Color(0.4, 0.8, 1.0, 0.07) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.07)
	circle.line_color  = Color(0.4, 0.8, 1.0, 0.45) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.45)
	range_circle.add_child(circle)

# ============================================================
# GAME LOOP
# ============================================================
func _process(delta):
	if battle_ref == null:
		return

	if unit_type == "melee":
		_process_melee(delta)
	else:
		_process_ranged(delta)

# --- MELEE: grab + block musuh yang masuk radius, serang mereka ---
func _process_melee(delta):
	# Coba grab musuh yang masuk radius
	_try_block_enemies()

	# Serang semua musuh yang ter-block
	attack_timer += delta
	if attack_timer >= attack_cd and blocking.size() > 0:
		attack_timer = 0.0
		for enemy in blocking:
			if is_instance_valid(enemy):
				_attack_enemy(enemy)

# --- RANGED: cari musuh dalam range, serang ---
func _process_ranged(delta):
	attack_timer += delta
	if attack_timer >= attack_cd:
		var target = _find_nearest_enemy()
		if target != null:
			attack_timer = 0.0
			_attack_enemy(target)

# ============================================================
# BLOCK SYSTEM (melee)
# Spirit berdiri di GROUND, grab musuh yang lewat di PATH
# dalam radius 1.2 tile di sekitarnya
# ============================================================
const BLOCK_RADIUS_TILES := 1.2

func _try_block_enemies():
	# Bersihkan slot yang sudah invalid
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

# Dipanggil oleh enemy.gd saat musuh mati/selesai ter-block
func on_enemy_cleared(enemy: Node2D):
	blocking.erase(enemy)

# ============================================================
# CARI MUSUH DALAM RANGE (ranged)
# ============================================================
func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist    := attack_range * tile_size

	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := position.distance_to(enemy.position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest      = enemy

	return nearest

# ============================================================
# SERANG MUSUH
# ============================================================
func _attack_enemy(target: Node2D):
	if not is_instance_valid(target):
		return

	# Flip ke arah musuh — anim_sprite atau live2d_model, mana yang aktif
	var facing_node: Node2D = live2d_model if is_live2d else anim_sprite
	if facing_node and is_instance_valid(facing_node):
		facing_node.scale.x = -abs(facing_node.scale.x) \
			if target.position.x < position.x \
			else abs(facing_node.scale.x)

	# Flash saat attack
	modulate = Color(1.5, 1.4, 0.5)
	_spawn_projectile(target.position)
	target.take_damage(atk)

	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

# ============================================================
# PROYEKTIL
# ============================================================
func _spawn_projectile(target_pos: Vector2):
	var proj        = ColorRect.new()
	proj.size       = Vector2(8, 8)
	proj.color      = Color(1.0, 0.85, 0.2) if unit_type == "ranged" else Color(1.0, 0.4, 0.2)
	proj.position   = position - Vector2(4, 4)
	proj.z_index    = 5
	get_parent().add_child(proj)

	var tween = get_tree().create_tween()
	tween.tween_property(proj, "position", target_pos - Vector2(4, 4), 0.16)
	tween.tween_callback(proj.queue_free)

# ============================================================
# INPUT — klik kiri spirit untuk toggle range indicator
# ============================================================
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var mouse_pos := get_global_mouse_position()
		if position.distance_to(mouse_pos) < tile_size * 0.5:
			_range_visible = not _range_visible
			range_circle.visible = _range_visible

# ============================================================
# INNER CLASS — gambar lingkaran range
# ============================================================
class _CircleDrawer extends Node2D:
	var radius:     float   = 256.0
	var fill_color: Color   = Color(0.4, 0.8, 1.0, 0.07)
	var line_color: Color   = Color(0.4, 0.8, 1.0, 0.45)

	func _draw():
		draw_circle(Vector2.ZERO, radius, fill_color)
		var pts := 60
		for i in range(pts):
			var a1 = TAU * i / pts
			var a2 = TAU * (i + 1) / pts
			draw_line(
				Vector2(cos(a1), sin(a1)) * radius,
				Vector2(cos(a2), sin(a2)) * radius,
				line_color, 1.5
			)
