extends Node2D

# ============================================================
# STAT (diisi lewat init() dari data SPIRIT_ROSTER)
# ============================================================
var spirit_id:   String = ""
var unit_type:   String = "melee"   # "melee" | "ranged"
var hp:          int    = 500
var max_hp:      int    = 500
var atk:         int    = 1
# phys_def/magic_def disimpan terpisah untuk Fase 2+ (damage type system),
# tapi untuk take_damage() sekarang dipakai rata-ratanya sebagai reduksi flat
# (lihat SPIRIT_COVENANT_ECONOMY.md 5c — sistem Physical/Magic DEF belum
# diimplementasi penuh, ini starting point sementara)
var phys_def:    int    = 0
var magic_def:   int    = 0

# ============================================================
# ATTACK PATTERN — grid-based ala Arknights, BUKAN radius lingkaran.
# attack_patterns = Dictionary 4 arah ("up"/"down"/"left"/"right"),
# masing-masing berisi list Vector2i offset (dx, dy) relatif ke tile
# Spirit, SUDAH didefinisikan eksplisit per arah dari roster — BUKAN
# dihitung dari rotasi matematis basis tunggal. Ini karena beberapa
# Spirit (misal Raookami) punya bentuk NON-RIGID: susunan tile-nya
# tidak simetris rotasi 90° (posisi tile pendamping bisa "pindah
# pasangan" tergantung sumbu arah, bukan sekadar berputar bersama).
# Musuh yang tile-nya match salah satu offset di array arah aktif
# dianggap dalam attack range — independen dari radius block.
# ============================================================
var attack_patterns: Dictionary = {}   # "up"/"down"/"left"/"right" → Array[Vector2i], diisi dari roster lewat init()
var facing_dir: Vector2i  = Vector2i(0, -1)   # default utara

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

# Basis scale.x asli sprite/model saat pertama dibangun (SEBELUM ada flip
# apapun). Dipakai sebagai referensi "menghadap default" yang aman — tidak
# mengasumsikan default absolut kanan/kiri, karena tiap asset (terutama
# model Live2D custom) bisa beda orientasi native-nya.
var base_facing_scale_x: float = 1.0

var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect

signal spirit_died

# ============================================================
# INIT — dipanggil dari battle.gd setelah add_child
# ============================================================
func init(battle: Node, data: Dictionary):
	battle_ref   = battle
	spirit_id    = data.get("id", "")
	unit_type    = data.get("unit_type", "melee")
	hp           = data.get("hp", 500)
	max_hp       = hp
	atk          = data.get("atk", 1)
	phys_def     = data.get("phys_def", 0)
	magic_def    = data.get("magic_def", 0)
	attack_patterns = data.get("attack_patterns", {"up": [Vector2i(0, -1)]})
	attack_cd    = data.get("atk_spd", 1.5)
	block_count  = data.get("block", 1)
	_build_visuals()
	_build_hp_bar()

func _ready():
	_build_range_indicator()

# ============================================================
# ARAH HADAP — dipanggil battle.gd SETELAH pemain pilih arah lewat
# UI 4-panah post-drop. Mengubah facing_dir, lalu refresh indikator
# visual (kotak-kotak pattern) dan orientasi sprite/model.
# ============================================================
func set_facing(dir: Vector2i):
	facing_dir = dir
	_apply_facing_visual()
	if range_circle:
		_refresh_range_indicator()

# Ambil array offset attack_patterns sesuai facing_dir sekarang.
# TIDAK ada rotasi matematis di sini — tiap arah sudah didefinisikan
# eksplisit di roster (lihat komentar attack_patterns di atas), karena
# beberapa Spirit punya bentuk non-rigid yang tidak bisa dihasilkan
# dari rotasi 90° basis tunggal.
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

# Sprite/model TIDAK di-flip berdasar facing_dir (arah pattern serang).
# Facing visual itu hal terpisah — lihat _attack_enemy() untuk flip
# kosmetik yang mengikuti posisi musuh yang sedang diserang.
func _apply_facing_visual():
	pass

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
		base_facing_scale_x = anim_sprite.scale.x

# ============================================================
# HP BAR + SKILL ENERGY BAR — ditaruh di BAWAH unit (bukan atas
# kepala), style Arknights: HP bar di atas, skill energy bar di
# bawahnya. Skill energy bar masih placeholder murni visual —
# belum ada logic pengisian gauge (itu Fase 2 - Skill System),
# jadi untuk sekarang statis kosong (size.x = 0).
#
# z_index tinggi (10) supaya tidak ketutup musuh/unit lain yang
# posisinya numpuk di tile yang sama — sebelumnya bar ditaruh di
# atas kepala dengan z_index rendah dan gampang ketutup elemen
# lain yang di-add_child belakangan (urutan add_child menentukan
# render order untuk node dengan z_index sama).
# ============================================================
const BAR_WIDTH := 58.0
const BAR_Y_HP    := 58.0   # HP bar — dijauhkan lagi dari kaki unit (sebelumnya 46, nempel)
const BAR_Y_SKILL := 65.0   # Skill energy bar — di bawah HP bar

var skill_bar_bg: ColorRect
var skill_bar_fill: ColorRect

func _build_hp_bar():
	# --- HP bar ---
	hp_bar_bg          = ColorRect.new()
	hp_bar_bg.size     = Vector2(BAR_WIDTH, 4)
	hp_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_bg.color    = Color(0.12, 0.12, 0.12, 0.9)
	hp_bar_bg.z_index  = 10
	add_child(hp_bar_bg)

	hp_bar_fill          = ColorRect.new()
	hp_bar_fill.size     = Vector2(BAR_WIDTH, 4)
	hp_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_fill.color    = Color(0.3, 0.7, 1.0)
	hp_bar_fill.z_index  = 10
	add_child(hp_bar_fill)

	# --- Skill energy bar (placeholder, belum ada logic gauge) ---
	skill_bar_bg          = ColorRect.new()
	skill_bar_bg.size     = Vector2(BAR_WIDTH, 3)
	skill_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_bg.color    = Color(0.12, 0.12, 0.12, 0.9)
	skill_bar_bg.z_index  = 10
	add_child(skill_bar_bg)

	skill_bar_fill          = ColorRect.new()
	skill_bar_fill.size     = Vector2(0, 3)   # kosong — belum ada gauge system
	skill_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_fill.color    = Color(1.0, 0.75, 0.2)
	skill_bar_fill.z_index  = 10
	add_child(skill_bar_fill)

func _update_hp_bar():
	if hp_bar_fill == null:
		return
	var ratio := float(hp) / float(max_hp)
	hp_bar_fill.size.x = BAR_WIDTH * ratio
	if ratio > 0.5:
		hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	elif ratio > 0.25:
		hp_bar_fill.color = Color(0.9, 0.75, 0.1)
	else:
		hp_bar_fill.color = Color(0.9, 0.2, 0.2)

# ============================================================
# TERIMA DAMAGE DARI MUSUH (saat sedang mem-block)
# DEF dipakai sebagai rata-rata phys_def/magic_def sementara —
# damage type system penuh (Physical vs Magic) belum ada, itu
# ranahnya Fase 2+. Reduksi minimal 1 supaya serangan tetap ada
# efek walau DEF tinggi.
# ============================================================
func take_damage(amount: int):
	var def_avg := (phys_def + magic_def) / 2.0
	var reduced := maxi(1, amount - int(def_avg))
	hp -= reduced
	_update_hp_bar()

	modulate = Color(1.0, 0.4, 0.4)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

	if hp <= 0:
		_die()

func _die():
	# Lepas semua musuh yang sedang di-block spirit ini sebelum spirit hilang,
	# sama seperti retreat manual — supaya musuh langsung lanjut jalan tanpa
	# delay 1 frame kosong (pola yang sama dipakai battle.gd _try_retreat()).
	for enemy in blocking:
		if is_instance_valid(enemy):
			enemy.clear_blocked()
	emit_signal("spirit_died")
	queue_free()

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
	base_facing_scale_x = live2d_model.scale.x

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
# RANGE INDICATOR — kotak-kotak sesuai attack_pattern (grid-based,
# ala Arknights), BUKAN lingkaran radius. Menampilkan tile mana saja
# yang masuk attack range Spirit ini, sesuai facing_dir sekarang.
# ============================================================
func _build_range_indicator():
	range_circle = Node2D.new()   # nama var dipertahankan, isinya sekarang grid pattern
	range_circle.z_index = -1
	range_circle.visible = false
	add_child(range_circle)
	_refresh_range_indicator()

func _refresh_range_indicator():
	if range_circle == null:
		return
	for child in range_circle.get_children():
		child.queue_free()

	# Tile Spirit sendiri (0,0), kalau ada di attack_pattern, digambar
	# dengan warna BERBEDA (biru) dari tile attack range lain (oranye/merah)
	# — bukan disembunyikan. Ini menandai "di sinilah Spirit berdiri", tapi
	# tetap bagian dari attack range kalau memang ada di pattern-nya
	# (contoh: Raookami — tile sendiri + atas/bawah/kiri, semua attack range).
	var rotated := _get_rotated_pattern()
	var self_offset  := rotated.filter(func(o): return o == Vector2i(0, 0))
	var other_offsets := rotated.filter(func(o): return o != Vector2i(0, 0))

	if self_offset.size() > 0:
		var self_drawer = _PatternDrawer.new()
		self_drawer.tile_size  = tile_size
		self_drawer.offsets    = self_offset
		self_drawer.fill_color = Color(0.2, 0.4, 1.0, 0.35)
		self_drawer.line_color = Color(0.2, 0.4, 1.0, 0.85)
		# z_index tinggi khusus kotak tile-sendiri — supaya tidak ketutup
		# badan sprite/model Spirit sendiri (yang render di z_index 1).
		# z_as_relative dimatikan supaya angka z_index di sini dihitung
		# ABSOLUT, bukan ditambah ke z_index parent (range_circle = -1) —
		# kalau relatif, 2 + (-1) cuma jadi 1, sama tingkat dengan sprite,
		# dan urutan gambar jadi tidak pasti (bisa ketutup lagi).
		# Kotak attack range lain di sekitar TETAP di belakang (ikut
		# z_index -1 dari parent), biar tidak menutupi unit lain yang
		# berdiri di tile tetangga.
		self_drawer.z_as_relative = false
		self_drawer.z_index = 2
		range_circle.add_child(self_drawer)

	var drawer = _PatternDrawer.new()
	drawer.tile_size  = tile_size
	drawer.offsets    = other_offsets
	drawer.fill_color = Color(0.4, 0.8, 1.0, 0.18) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.18)
	drawer.line_color = Color(0.4, 0.8, 1.0, 0.55) if unit_type == "ranged" else Color(1.0, 0.6, 0.2, 0.55)
	range_circle.add_child(drawer)

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

# --- MELEE: 2 lapis independen ---
# 1) Serang SEMUA musuh yang tile-nya match attack_pattern (bisa kena
#    musuh yang belum di-block sekalipun — attack_pattern adalah radius
#    deteksi/serang, bukan radius block)
# 2) Grab/block musuh yang sudah masuk BLOCK_RADIUS_TILES, dibatasi
#    block_count slot — begitu block penuh, musuh baru cuma lewat
#    (tidak ke-block, tapi tetap bisa kena serang kalau masih dalam
#    attack_pattern)
func _process_melee(delta):
	_try_block_enemies()

	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			for enemy in targets:
				if is_instance_valid(enemy):
					_attack_enemy(enemy)

# --- RANGED: sama, serang semua musuh dalam attack_pattern ---
func _process_ranged(delta):
	attack_timer += delta
	if attack_timer >= attack_cd:
		var targets := _find_enemies_in_pattern()
		if targets.size() > 0:
			attack_timer = 0.0
			# Ranged tetap fokus 1 target per serangan (nearest dalam pattern)
			_attack_enemy(targets[0])

# ============================================================
# CARI MUSUH YANG TILE-NYA MATCH attack_pattern (grid-based)
# Dipakai untuk deteksi/serang, terpisah dari block system.
# ============================================================
func _find_enemies_in_pattern() -> Array:
	var result := []
	var self_tile := Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	var rotated := _get_rotated_pattern()

	for enemy in battle_ref.active_enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_tile := Vector2i(int(enemy.position.x / tile_size), int(enemy.position.y / tile_size))
		var rel := enemy_tile - self_tile
		if rel in rotated:
			result.append(enemy)

	return result

# ============================================================
# BLOCK SYSTEM (melee)
# Spirit berdiri di GROUND, grab musuh yang lewat di PATH
# dalam radius 0.6 tile di sekitarnya (cuma musuh yang benar-benar
# di tile yang sama, bukan nyerempet ke tile tetangga — sebelumnya
# 1.2 tile kelewat luas, sempat nangkep musuh yang masih 1 tile
# jauhnya dari Spirit)
# ============================================================
const BLOCK_RADIUS_TILES := 0.6

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
# SERANG MUSUH
# ============================================================
# ============================================================
# KOREKSI ARAH — kalau setelah ditest ternyata sprite/model malah
# kebalik (menghadap kiri saat harusnya kanan atau sebaliknya),
# cukup ubah true/false di sini, tidak perlu sentuh logic manapun.
# ============================================================
const FACING_FLIP_CORRECTION := true

func _attack_enemy(target: Node2D):
	if not is_instance_valid(target):
		return

	# Flip kosmetik — sprite/model menghadap ke arah musuh yang sedang
	# diserang. Ini TERPISAH dari attack_pattern (yang fixed sesuai
	# facing_dir dari deploy) — murni visual, tidak mengubah mekanik.
	#
	# Dihitung relatif ke base_facing_scale_x (basis asli saat visual
	# pertama dibangun), BUKAN diasumsikan absolut "positif = kanan".
	# Sebelumnya kode lama pakai abs()/-abs() yang salah asumsi soal
	# orientasi default sprite/model, bikin karakter kelihatan
	# membelakangi musuh yang sedang diserang.
	var facing_node: Node2D = live2d_model if is_live2d else anim_sprite
	if facing_node and is_instance_valid(facing_node):
		var facing_left := target.position.x < position.x
		if FACING_FLIP_CORRECTION:
			facing_left = not facing_left
		facing_node.scale.x = -abs(base_facing_scale_x) if facing_left else abs(base_facing_scale_x)

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
# INNER CLASS — gambar kotak-kotak attack_pattern (grid-based,
# menggantikan _CircleDrawer lama berbasis radius lingkaran)
# ============================================================
class _PatternDrawer extends Node2D:
	var tile_size:  int     = 128
	var offsets:    Array   = []   # Array[Vector2i], sudah dirotasi sesuai facing_dir
	var fill_color: Color   = Color(0.4, 0.8, 1.0, 0.18)
	var line_color: Color   = Color(0.4, 0.8, 1.0, 0.55)

	func _draw():
		for offset in offsets:
			var top_left := Vector2(offset.x * tile_size - tile_size / 2.0,
									 offset.y * tile_size - tile_size / 2.0)
			var rect := Rect2(top_left, Vector2(tile_size, tile_size))
			draw_rect(rect, fill_color, true)
			draw_rect(rect, line_color, false, 2.0)
