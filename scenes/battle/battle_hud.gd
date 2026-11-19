class_name BattleHUD
extends CanvasLayer

signal speed_toggle_requested
signal pause_toggle_requested
signal retreat_requested
signal skill_requested
signal card_drag_started(data: SpiritData, mouse_pos: Vector2)

const ELEMENT_COLORS := {
	"Umbra": Color(0.55, 0.18, 0.65),
	"Flare": Color(1.0, 0.68, 0.15),
	"Tide": Color(0.15, 0.48, 0.92),
	"Rime": Color(0.82, 0.92, 1.0),
	"Veil": Color(0.22, 0.85, 0.65),
}

var battle_ref: Node = null

var crystal_hp_label: Label
var cp_label: Label
var cp_bar_fill: ColorRect
var wave_label: Label
var speed_btn: Button
var pause_btn: Button

var bottom_panel: Control
var card_nodes: Dictionary = {}

var retreat_panel: Control
var retreat_btn: Button
var skill_btn: Button
var selected_spirit_ref: Node2D = null


func setup(battle: Node):
	battle_ref = battle
	_create_hud()
	_create_bottom_panel()
	_create_retreat_panel()


func _process(_delta: float):
	if retreat_panel != null and retreat_panel.visible:
		if is_instance_valid(selected_spirit_ref):
			_sync_action_panel_pos(selected_spirit_ref)
		else:
			retreat_panel.visible = false
			selected_spirit_ref = null


func _create_hud():
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var hud_bg := ColorRect.new()
	hud_bg.size = Vector2(240, 36)
	hud_bg.position = Vector2(8, 8)
	hud_bg.color = Color(0, 0, 0, 0.55)
	root.add_child(hud_bg)

	crystal_hp_label = Label.new()
	crystal_hp_label.add_theme_font_size_override("font_size", 15)
	crystal_hp_label.position = Vector2(14, 12)
	root.add_child(crystal_hp_label)

	var cp_bg := ColorRect.new()
	cp_bg.size = Vector2(240, 36)
	cp_bg.position = Vector2(8, 50)
	cp_bg.color = Color(0, 0, 0, 0.55)
	root.add_child(cp_bg)

	var cp_track := ColorRect.new()
	cp_track.size = Vector2(150, 10)
	cp_track.position = Vector2(14, 68)
	cp_track.color = Color(0.2, 0.2, 0.2)
	root.add_child(cp_track)

	cp_bar_fill = ColorRect.new()
	cp_bar_fill.size = Vector2(0, 10)
	cp_bar_fill.position = Vector2(14, 68)
	cp_bar_fill.color = Color(0.5, 0.85, 1.0)
	root.add_child(cp_bar_fill)

	cp_label = Label.new()
	cp_label.add_theme_font_size_override("font_size", 13)
	cp_label.position = Vector2(170, 60)
	root.add_child(cp_label)

	wave_label = Label.new()
	wave_label.add_theme_font_size_override("font_size", 16)
	wave_label.position = Vector2(980, 12)
	root.add_child(wave_label)

	speed_btn = Button.new()
	speed_btn.text = "1x"
	speed_btn.size = Vector2(44, 32)
	speed_btn.position = Vector2(1170, 8)
	speed_btn.pressed.connect(func(): emit_signal("speed_toggle_requested"))
	root.add_child(speed_btn)

	pause_btn = Button.new()
	pause_btn.text = "⏸"
	pause_btn.size = Vector2(44, 32)
	pause_btn.position = Vector2(1222, 8)
	pause_btn.pressed.connect(func(): emit_signal("pause_toggle_requested"))
	root.add_child(pause_btn)


func _create_bottom_panel():
	bottom_panel = Control.new()
	bottom_panel.position = Vector2(0, 640)
	bottom_panel.size = Vector2(1280, 80)
	add_child(bottom_panel)

	var bg := ColorRect.new()
	bg.size = Vector2(1280, 80)
	bg.color = Color(0.06, 0.06, 0.10, 0.96)
	bottom_panel.add_child(bg)

	var border := ColorRect.new()
	border.size = Vector2(1280, 2)
	border.color = Color(0.35, 0.55, 0.75, 0.7)
	bottom_panel.add_child(border)

	for i in range(battle_ref.spirit_roster.size()):
		var data: SpiritData = battle_ref.spirit_roster[i]
		_create_card(data, i)


func _create_card(data: SpiritData, index: int):
	var card_x := 20 + index * 110
	var card_y := 5

	var card := Control.new()
	card.name = "Card_" + data.id
	card.position = Vector2(card_x, card_y)
	card.size = Vector2(96, 70)
	bottom_panel.add_child(card)
	card_nodes[data.id] = card
	card.set_meta("card_center", Vector2(34, 24))

	var card_bg := ColorRect.new()
	card_bg.size = Vector2(96, 70)
	card_bg.color = Color(0.12, 0.16, 0.22, 0.95)
	card.add_child(card_bg)

	var elem_color: Color = ELEMENT_COLORS.get(data.element, Color(0.7, 0.7, 0.8))

	var card_border := ColorRect.new()
	card_border.size = Vector2(96, 3)
	card_border.color = elem_color
	card.add_child(card_border)

	if data.texture_path != "" and ResourceLoader.exists(data.texture_path):
		var icon := Sprite2D.new()
		icon.texture = load(data.texture_path)
		icon.scale = Vector2(0.22, 0.22)
		icon.position = Vector2(48, 34)
		card.add_child(icon)
	else:
		var placeholder := ColorRect.new()
		placeholder.size = Vector2(54, 34)
		placeholder.position = Vector2(21, 18)
		placeholder.color = elem_color * Color(0.55, 0.55, 0.55, 0.9)
		card.add_child(placeholder)

	var name_lbl := Label.new()
	name_lbl.text = data.display_name
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.position = Vector2(4, 52)
	card.add_child(name_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "CP %d" % data.cp_cost
	cost_lbl.add_theme_font_size_override("font_size", 10)
	cost_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 0.5))
	cost_lbl.position = Vector2(4, 4)
	card.add_child(cost_lbl)

	var type_lbl := Label.new()
	var short_t := "M" if data.unit_type == "melee" else "R"
	type_lbl.text = "%s-%s" % [data.main_class.substr(0, 3).to_upper(), short_t]
	type_lbl.add_theme_font_size_override("font_size", 9)
	type_lbl.add_theme_color_override("font_color", elem_color)
	type_lbl.position = Vector2(56, 4)
	card.add_child(type_lbl)

	var trigger := Button.new()
	trigger.flat = true
	trigger.size = Vector2(96, 70)
	trigger.button_down.connect(func(): _on_card_button_down(data))
	card.add_child(trigger)


func _on_card_button_down(data: SpiritData):
	if battle_ref.can_start_drag_spirit(data.id, data.cp_cost):
		emit_signal("card_drag_started", data, get_viewport().get_mouse_position())


func _create_retreat_panel():
	retreat_panel = Control.new()
	retreat_panel.visible = false
	retreat_panel.z_index = 25
	retreat_panel.size = Vector2(176, 28)
	retreat_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(retreat_panel)

	retreat_btn = Button.new()
	retreat_btn.text = "↩ RETREAT"
	retreat_btn.size = Vector2(90, 28)
	retreat_btn.position = Vector2(0, 0)
	retreat_btn.pressed.connect(func(): emit_signal("retreat_requested"))
	retreat_panel.add_child(retreat_btn)

	skill_btn = Button.new()
	skill_btn.text = "✦ SKILL"
	skill_btn.size = Vector2(80, 28)
	skill_btn.position = Vector2(96, 0)
	skill_btn.pressed.connect(func(): emit_signal("skill_requested"))
	retreat_panel.add_child(skill_btn)


func _sync_action_panel_pos(spirit: Node2D):
	var screen_pos := spirit.get_global_transform_with_canvas().origin
	retreat_panel.position = screen_pos + Vector2(-88, -88)


func update_crystal(hp: int, max_hp: int):
	if crystal_hp_label == null:
		return
	crystal_hp_label.text = "💎 Crystal: %d / %d" % [hp, max_hp]
	var ratio := float(hp) / float(maxi(1, max_hp))
	if ratio <= 0.3:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	elif ratio <= 0.6:
		crystal_hp_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	else:
		crystal_hp_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.9))


func update_cp(cp: float, cp_max: int, cp_frozen: bool):
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


func update_wave(info: Dictionary):
	if wave_label == null:
		return
	wave_label.text = "Wave: %d / %d" % [info["current"], info["total"]]


func update_cards(
	cp: float,
	deployed_map: Dictionary,
	cooldown_map: Dictionary,
	spirit_roster: Array[SpiritData]
):
	for data in spirit_roster:
		var sid := data.id
		var card: Control = card_nodes.get(sid)
		if card == null:
			continue
		var can_afford: bool = int(cp) >= data.cp_cost
		var is_deployed: bool = deployed_map.get(sid, false)
		var cd: float = cooldown_map.get(sid, 0.0)
		var is_ready: bool = can_afford and not is_deployed and cd <= 0.0

		card.modulate = Color(1, 1, 1, 1) if is_ready else Color(0.4, 0.4, 0.4, 0.7)

		var cd_lbl: Label = card.get_node_or_null("CooldownLabel")
		if cd > 0.0:
			if cd_lbl == null:
				cd_lbl = Label.new()
				cd_lbl.name = "CooldownLabel"
				cd_lbl.add_theme_font_size_override("font_size", 16)
				cd_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
				card.add_child(cd_lbl)
			cd_lbl.text = "%ds" % int(ceil(cd))
			cd_lbl.position = card.get_meta("card_center", Vector2.ZERO)
			cd_lbl.visible = true
		elif cd_lbl != null:
			cd_lbl.visible = false


func update_selected_spirit(spirit: Node2D):
	selected_spirit_ref = spirit
	if spirit == null or not is_instance_valid(spirit):
		retreat_panel.visible = false
		return
	retreat_panel.visible = true
	_sync_action_panel_pos(spirit)


func set_speed_text(speed_scale: float):
	if speed_btn:
		speed_btn.text = "2x" if speed_scale > 1.2 else "1x"


func set_pause_text(is_paused: bool):
	if pause_btn:
		pause_btn.text = "▶" if is_paused else "⏸"


func show_result(text: String, color: Color):
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