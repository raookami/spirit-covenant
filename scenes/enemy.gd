extends Node2D

# ============================================================
# 🧪 TEST SEMENTARA — HAPUS/SET FALSE SETELAH SELESAI TEST 🧪
# Boost HP + block_atk musuh biar cukup kuat & tanky buat stress-test
# spirit.gd take_damage()/mati. Musuh default (hp=5) mati kelewat cepat
# sebelum sempat nge-hit balik Spirit yang HP-nya 350-1200.
# ============================================================
const TESTING_TANKY_ENEMY := true

# ============================================================
# STAT MUSUH
# ============================================================
var hp: int        = 5
var max_hp: int    = 5
var speed: float   = 80.0
var tile_size: int = 128

# ============================================================
# PATHFINDING STATE
# ============================================================
var path: Array        = []
var path_index: int    = 0
var target_pos: Vector2 = Vector2.ZERO
var reached_end: bool  = false
var _initialized: bool = false

# ============================================================
# BLOCK STATE
# Kalau blocked_by != null, musuh berhenti dan menyerang spirit
# ============================================================
var blocked_by: Node2D = null   # referensi spirit yang mem-block
var block_attack_timer: float = 0.0
var block_attack_cd: float    = 1.0  # musuh serang spirit per 1 detik
var block_atk: int            = 1    # damage musuh ke spirit yang mem-block-nya

# ============================================================
# NODE REFERENSI
# ============================================================
var sprite: Sprite2D
var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect

var enemy_texture = preload("res://assets/spirites/enemies/enemy1.png")

# ============================================================
# SINYAL
# ============================================================
signal enemy_reached_end
signal enemy_died

# ============================================================
# SETUP
# ============================================================
# Urutan yang benar: panggil setup() SEBELUM add_child() ke tree, supaya
# `path` sudah terisi saat _ready() jalan. Cek _initialized di bawah ini
# cuma safety net kalau ada pemanggilan dari tempat lain dengan urutan kebalik.
func setup(enemy_path: Array):
	path = enemy_path
	if _initialized:
		_init_position()

func _ready():
	if TESTING_TANKY_ENEMY:
		# 🧪 Boost sementara buat stress-test Spirit take_damage()/mati.
		# HP tinggi = musuh tahan lama kena serang Spirit → block_atk tinggi
		# = HP Spirit kelihatan turun cepat & bisa habis buat lihat _die().
		hp          = 560
		max_hp      = 560
		block_atk   = 10

	_initialized = true
	_build_visuals()
	if path.size() > 0:
		_init_position()

# ============================================================
# VISUAL
# ============================================================
func _build_visuals():
	sprite = Sprite2D.new()
	sprite.texture = enemy_texture
	sprite.scale   = Vector2(0.5, 0.5)
	add_child(sprite)

	# HP bar background
	hp_bar_bg          = ColorRect.new()
	hp_bar_bg.size     = Vector2(46, 6)
	hp_bar_bg.position = Vector2(-23, -50)
	hp_bar_bg.color    = Color(0.12, 0.12, 0.12, 0.9)
	add_child(hp_bar_bg)

	# HP bar fill
	hp_bar_fill          = ColorRect.new()
	hp_bar_fill.size     = Vector2(46, 6)
	hp_bar_fill.position = Vector2(-23, -50)
	hp_bar_fill.color    = Color(0.15, 0.85, 0.3)
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

# ============================================================
# POSISI AWAL
# ============================================================
func _init_position():
	if path.size() < 2:
		return
	position = Vector2(
		path[0][0] * tile_size + tile_size / 2,
		path[0][1] * tile_size + tile_size / 2
	)
	path_index = 1
	target_pos = Vector2(
		path[1][0] * tile_size + tile_size / 2,
		path[1][1] * tile_size + tile_size / 2
	)

# ============================================================
# GAME LOOP
# ============================================================
func _process(delta):
	if reached_end:
		return

	# --- MODE BLOCKED: berhenti, serang spirit ---
	if blocked_by != null:
		if not is_instance_valid(blocked_by):
			# Spirit sudah mati/retreat — lanjut jalan
			blocked_by = null
		else:
			block_attack_timer += delta
			if block_attack_timer >= block_attack_cd:
				block_attack_timer = 0.0
				_attack_blocker()
			return  # tidak bergerak selama ter-block

	# --- MODE NORMAL: jalan mengikuti path ---
	if path.size() == 0 or path_index == 0:
		return

	var dir := (target_pos - position).normalized()
	position += dir * speed * delta

	# Flip sprite horizontal
	if dir.x < -0.1:
		sprite.scale.x = -abs(sprite.scale.x)
	elif dir.x > 0.1:
		sprite.scale.x = abs(sprite.scale.x)

	# Cek waypoint tercapai
	if position.distance_to(target_pos) < 4.0:
		position = target_pos
		path_index += 1
		if path_index >= path.size():
			reached_end = true
			emit_signal("enemy_reached_end")
			queue_free()
		else:
			target_pos = Vector2(
				path[path_index][0] * tile_size + tile_size / 2,
				path[path_index][1] * tile_size + tile_size / 2
			)

# ============================================================
# MUSUH SERANG SPIRIT YANG MEM-BLOCK
# (siap untuk sistem HP spirit nanti)
# ============================================================
func _attack_blocker():
	if not is_instance_valid(blocked_by):
		return
	blocked_by.take_damage(block_atk)
	modulate = Color(1.0, 0.6, 0.6)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

# ============================================================
# DIPANGGIL SPIRIT MELEE — set musuh ini ter-block
# Musuh tetap di posisinya di PATH, hanya berhenti jalan
# ============================================================
func set_blocked(spirit: Node2D):
	if blocked_by != null:
		return
	blocked_by = spirit
	# Tidak snap posisi — musuh berhenti di tempat dia sekarang (di PATH)

# ============================================================
# DIPANGGIL SPIRIT — musuh dilepas dari block (spirit retreat)
# ============================================================
func clear_blocked():
	blocked_by         = null
	block_attack_timer = 0.0

# ============================================================
# TERIMA DAMAGE DARI SPIRIT
# ============================================================
func take_damage(amount: int):
	hp -= amount
	_update_hp_bar()

	modulate = Color(1.0, 0.3, 0.3)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1)

	if hp <= 0:
		# Lepaskan block sebelum mati
		if blocked_by != null and is_instance_valid(blocked_by):
			blocked_by.on_enemy_cleared(self)
		emit_signal("enemy_died")
		queue_free()
