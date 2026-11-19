class_name CovenantLinkController
extends Node2D

signal link_activated
signal link_ended

const DURATION := 10.0

var battle_ref: Node = null
var link_used: bool = false
var is_active: bool = false
var timer: float = 0.0

var border_top: ColorRect
var border_bottom: ColorRect
var border_left: ColorRect
var border_right: ColorRect
var aura_tint: ColorRect
var banner_label: Label


func setup(battle: Node):
	battle_ref = battle
	_build_visuals()


func _build_visuals():
	# Aura halus semi-transparan di seluruh layar
	aura_tint = ColorRect.new()
	aura_tint.size = Vector2(1280, 720)
	aura_tint.color = Color(0.35, 0.22, 0.70, 0.08)
	aura_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aura_tint.z_index = 18
	aura_tint.visible = false
	add_child(aura_tint)

	# Border glow di 4 sisi layar (tebal 8px)
	var glow_color := Color(0.65, 0.85, 1.0, 0.85)

	border_top = ColorRect.new()
	border_top.size = Vector2(1280, 8)
	border_top.position = Vector2(0, 0)
	border_top.color = glow_color
	border_top.z_index = 19
	border_top.visible = false
	add_child(border_top)

	border_bottom = ColorRect.new()
	border_bottom.size = Vector2(1280, 8)
	border_bottom.position = Vector2(0, 712)
	border_bottom.color = glow_color
	border_bottom.z_index = 19
	border_bottom.visible = false
	add_child(border_bottom)

	border_left = ColorRect.new()
	border_left.size = Vector2(8, 720)
	border_left.position = Vector2(0, 0)
	border_left.color = glow_color
	border_left.z_index = 19
	border_left.visible = false
	add_child(border_left)

	border_right = ColorRect.new()
	border_right.size = Vector2(8, 720)
	border_right.position = Vector2(1272, 0)
	border_right.color = glow_color
	border_right.z_index = 19
	border_right.visible = false
	add_child(border_right)

	banner_label = Label.new()
	banner_label.text = ""
	banner_label.add_theme_font_size_override("font_size", 18)
	banner_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	banner_label.position = Vector2(440, 12)
	banner_label.z_index = 20
	banner_label.visible = false
	add_child(banner_label)


func try_trigger(breaching_enemy: Node2D) -> bool:
	if link_used or is_active:
		return false

	link_used = true
	is_active = true
	timer = DURATION

	# Knockback musuh mundur (5 tile untuk boss, 3 tile untuk biasa/elite)
	var knockback := 5 if breaching_enemy.tier == "boss" else 3
	breaching_enemy.push_back_tiles(knockback)

	_set_visuals_visible(true)
	emit_signal("link_activated")
	return true


func process_link(delta: float):
	if not is_active:
		return

	timer -= delta
	if banner_label:
		banner_label.text = "⚡ COVENANT LINK! %.1fs | CP BEKU" % maxf(0.0, timer)

	if timer <= 0.0:
		is_active = false
		_set_visuals_visible(false)
		emit_signal("link_ended")


func _set_visuals_visible(should_show: bool):
	if aura_tint:
		aura_tint.visible = should_show
	if border_top:
		border_top.visible = should_show
		border_bottom.visible = should_show
		border_left.visible = should_show
		border_right.visible = should_show
	if banner_label:
		banner_label.visible = should_show