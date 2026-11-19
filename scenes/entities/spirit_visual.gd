class_name SpiritVisual
extends Node2D

const BAR_WIDTH := 58.0
const BAR_Y_HP := 48.0
const BAR_Y_SKILL := 54.0
const FACING_FLIP_CORRECTION := true
const LIVE2D_VIEWPORT_SIZE := 512

const ELEMENT_COLORS := {
	"Umbra": Color(0.55, 0.18, 0.65),
	"Flare": Color(1.0, 0.68, 0.15),
	"Tide": Color(0.15, 0.48, 0.92),
	"Rime": Color(0.82, 0.92, 1.0),
	"Veil": Color(0.22, 0.85, 0.65),
}

var anim_sprite: AnimatedSprite2D
var static_sprite: Sprite2D
var live2d_viewport: SubViewport
var live2d_sprite: Sprite2D
var live2d_model: Node2D
var is_live2d: bool = false
var base_facing_scale_x: float = 1.0
var last_face_left: bool = false

var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect
var skill_bar_bg: ColorRect
var skill_bar_fill: ColorRect
var shield_border: ColorRect


func setup(_spirit: Node2D, data: SpiritData):
	_build_visuals(data)
	_build_bars(data)


func _build_visuals(data: SpiritData):
	var model_path := (
		"res://assets/spirites/characters/%s/%s_idle.model3.json" % [data.id, data.id]
	)
	if ResourceLoader.exists(model_path) and ClassDB.can_instantiate("GDCubismUserModel"):
		_build_live2d(model_path)
		_add_type_badge(data)
		return

	anim_sprite = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 12)

	var loaded_any := false
	for i in range(24):
		var f_path := (
			"res://assets/spirites/characters/%s/%s_idle_%04d.png" % [data.id, data.id, i]
		)
		if ResourceLoader.exists(f_path):
			frames.add_frame("idle", load(f_path))
			loaded_any = true

	if loaded_any:
		anim_sprite.sprite_frames = frames
		anim_sprite.scale = Vector2(0.6, 0.6)
		anim_sprite.z_index = 1
		anim_sprite.play("idle")
		add_child(anim_sprite)
		base_facing_scale_x = anim_sprite.scale.x
	elif data.texture_path != "" and ResourceLoader.exists(data.texture_path):
		var tex: Texture2D = load(data.texture_path)
		static_sprite = Sprite2D.new()
		static_sprite.texture = tex
		var t_size := tex.get_size()
		var fit_scale := 82.0 / maxf(1.0, maxf(t_size.x, t_size.y))
		static_sprite.scale = Vector2(fit_scale, fit_scale)
		static_sprite.z_index = 1
		add_child(static_sprite)
		base_facing_scale_x = static_sprite.scale.x
	else:
		var placeholder := ColorRect.new()
		placeholder.size = Vector2(52, 52)
		placeholder.position = Vector2(-26, -34)
		placeholder.color = ELEMENT_COLORS.get(data.element, Color(0.5, 0.5, 0.6))
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(placeholder)

	_add_type_badge(data)


func _build_live2d(model_path: String):
	is_live2d = true

	live2d_viewport = SubViewport.new()
	live2d_viewport.transparent_bg = true
	live2d_viewport.disable_3d = true
	live2d_viewport.gui_disable_input = true
	live2d_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	live2d_viewport.size = Vector2i(LIVE2D_VIEWPORT_SIZE, LIVE2D_VIEWPORT_SIZE)
	add_child(live2d_viewport)

	live2d_model = ClassDB.instantiate("GDCubismUserModel")
	live2d_model.assets = model_path
	live2d_model.scale = Vector2(0.1, 0.1)
	live2d_model.position = Vector2(
		LIVE2D_VIEWPORT_SIZE * 0.5,
		LIVE2D_VIEWPORT_SIZE * 0.5
	)
	live2d_viewport.add_child(live2d_model)
	live2d_model.start_motion_loop("Idle", 0, 1, true, true)

	live2d_sprite = Sprite2D.new()
	live2d_sprite.texture = live2d_viewport.get_texture()
	live2d_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	live2d_sprite.position = Vector2(0, -20)
	live2d_sprite.z_index = 1
	add_child(live2d_sprite)
	base_facing_scale_x = live2d_sprite.scale.x


func _add_type_badge(data: SpiritData):
	var type_lbl := Label.new()
	var short_type := "M" if data.unit_type == "melee" else "R"
	type_lbl.text = "%s [%s]" % [data.main_class.substr(0, 3).to_upper(), short_type]
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override(
		"font_color", ELEMENT_COLORS.get(data.element, Color(1, 1, 1))
	)
	type_lbl.position = Vector2(-24, -56)
	type_lbl.z_index = 10
	add_child(type_lbl)


func _build_bars(data: SpiritData):
	shield_border = ColorRect.new()
	shield_border.size = Vector2(BAR_WIDTH + 4, 8)
	shield_border.position = Vector2(-BAR_WIDTH / 2 - 2, BAR_Y_HP - 2)
	shield_border.color = Color(0.55, 0.85, 1.0, 0.95)
	shield_border.z_index = 9
	shield_border.visible = false
	shield_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shield_border)

	hp_bar_bg = ColorRect.new()
	hp_bar_bg.size = Vector2(BAR_WIDTH, 4)
	hp_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_bg.color = Color(0.12, 0.12, 0.12, 0.9)
	hp_bar_bg.z_index = 10
	hp_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_bar_bg)

	hp_bar_fill = ColorRect.new()
	hp_bar_fill.size = Vector2(BAR_WIDTH, 4)
	hp_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_HP)
	hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	hp_bar_fill.z_index = 10
	hp_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_bar_fill)

	skill_bar_bg = ColorRect.new()
	skill_bar_bg.size = Vector2(BAR_WIDTH, 4)
	skill_bar_bg.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_bg.color = Color(0.12, 0.12, 0.12, 0.9)
	skill_bar_bg.z_index = 10
	skill_bar_bg.visible = data.cp_gen_interval > 0.0
	skill_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(skill_bar_bg)

	skill_bar_fill = ColorRect.new()
	skill_bar_fill.size = Vector2(0, 4)
	skill_bar_fill.position = Vector2(-BAR_WIDTH / 2, BAR_Y_SKILL)
	skill_bar_fill.color = Color(1.0, 0.85, 0.1)
	skill_bar_fill.z_index = 10
	skill_bar_fill.visible = data.cp_gen_interval > 0.0
	skill_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(skill_bar_fill)


func update_hp_bar(hp: int, max_hp: int, is_invincible: bool):
	if hp_bar_fill == null:
		return
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	hp_bar_fill.size.x = BAR_WIDTH * ratio
	if is_invincible:
		hp_bar_fill.color = Color(0.7, 0.95, 1.0)
	elif ratio > 0.5:
		hp_bar_fill.color = Color(0.3, 0.7, 1.0)
	elif ratio > 0.25:
		hp_bar_fill.color = Color(0.9, 0.75, 0.1)
	else:
		hp_bar_fill.color = Color(0.9, 0.2, 0.2)


func update_skill_bar(
	cp_timer: float,
	cp_interval: float,
	link_active: bool,
	link_timer: float
):
	if skill_bar_fill == null or skill_bar_bg == null:
		return
	if link_active:
		skill_bar_bg.visible = true
		skill_bar_fill.visible = true
		skill_bar_fill.color = Color(0.6, 0.9, 1.0)
		var ratio := clampf(link_timer / 10.0, 0.0, 1.0)
		skill_bar_fill.size.x = BAR_WIDTH * ratio
	elif cp_interval > 0.0:
		skill_bar_bg.visible = true
		skill_bar_fill.visible = true
		skill_bar_fill.color = Color(1.0, 0.85, 0.1)
		var ratio := clampf(cp_timer / cp_interval, 0.0, 1.0)
		skill_bar_fill.size.x = BAR_WIDTH * ratio
	else:
		skill_bar_bg.visible = false
		skill_bar_fill.visible = false


func set_shield_visible(should_show: bool):
	if shield_border:
		shield_border.visible = should_show


func apply_facing(facing_dir: Vector2i):
	if facing_dir.x < 0:
		last_face_left = true
	elif facing_dir.x > 0:
		last_face_left = false

	if is_live2d and is_instance_valid(live2d_sprite):
		var should_flip := not last_face_left if FACING_FLIP_CORRECTION else last_face_left
		live2d_sprite.flip_h = should_flip
		return

	var node := _get_active_node()
	if node == null or not is_instance_valid(node):
		return
	var abs_scale := absf(base_facing_scale_x)
	node.scale.x = - abs_scale if last_face_left else abs_scale


func _get_active_node() -> Node2D:
	if is_live2d and is_instance_valid(live2d_sprite):
		return live2d_sprite
	if is_instance_valid(anim_sprite) and anim_sprite.sprite_frames != null:
		if anim_sprite.sprite_frames.get_frame_count("idle") > 0:
			return anim_sprite
	if is_instance_valid(static_sprite):
		return static_sprite
	return null