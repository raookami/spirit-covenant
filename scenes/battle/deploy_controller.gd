class_name DeployController
extends Node2D

# ============================================================
# 1. SIGNALS (Wajib paling atas setelah extends)
# ============================================================
signal slowmo_requested(active: bool)
signal spirit_deployed_successfully(spirit_node: Node2D, tile_key: String, sid: String)
signal retreat_executed(sid: String, tile_key: String)
signal spirit_selected_changed(spirit_node: Node2D)

# ============================================================
# 2. CONSTANTS
# ============================================================
const SPIRIT_SCRIPT = preload("res://scenes/entities/spirit.gd")

# ============================================================
# 3. VARIABLES
# ============================================================
var battle_ref: Node = null
var tile_size: int = 128

var dragging := false
var drag_spirit_id := ""
var drag_sprite: Sprite2D = null

var choosing_direction := false
var is_redirecting := false
var pending_deploy_data: SpiritData = null
var pending_deploy_tile: Vector2i = Vector2i.ZERO
var preview_spirit: Node2D = null
var swipe_start_pos := Vector2.ZERO
var current_facing_dir := Vector2i(1, 0)
var original_facing_dir := Vector2i(1, 0)
var swipe_started := false

var selected_spirit: Node2D = null
var _last_highlighted_tile: String = ""


# ============================================================
# 4. FUNCTIONS
# ============================================================
func setup(battle: Node, size: int):
	battle_ref = battle
	tile_size = size


func handle_card_start_drag(data: SpiritData, _mouse_pos: Vector2):
	if selected_spirit != null:
		deselect_spirit()
	if choosing_direction:
		cancel_direction_mode()

	dragging = true
	drag_spirit_id = data.id
	emit_signal("slowmo_requested", true)

	drag_sprite = Sprite2D.new()
	drag_sprite.scale = Vector2(0.35, 0.35)
	drag_sprite.position = get_global_mouse_position()
	drag_sprite.modulate = Color(1, 1, 1, 0.75)
	drag_sprite.z_index = 10

	if data.texture_path != "" and ResourceLoader.exists(data.texture_path):
		drag_sprite.texture = load(data.texture_path)

	add_child(drag_sprite)


func handle_direction_press(mouse_pos: Vector2):
	if not choosing_direction:
		return
	swipe_started = true
	swipe_start_pos = mouse_pos
	if is_instance_valid(preview_spirit):
		preview_spirit.toggle_range_indicator(true)


func handle_mouse_motion(mouse_pos: Vector2):
	if choosing_direction and swipe_started and is_instance_valid(preview_spirit):
		var diff := mouse_pos - swipe_start_pos
		if diff.length() >= 12.0:
			var dir := Vector2i.RIGHT
			if absf(diff.x) > absf(diff.y):
				dir = Vector2i(-1, 0) if diff.x < 0 else Vector2i(1, 0)
			else:
				dir = Vector2i(0, -1) if diff.y < 0 else Vector2i(0, 1)
			if dir != current_facing_dir:
				current_facing_dir = dir
				preview_spirit.set_facing(current_facing_dir)
	if dragging and is_instance_valid(drag_sprite):
		drag_sprite.position = mouse_pos
		_update_drag_tint(mouse_pos)


func handle_mouse_up(mouse_pos: Vector2):
	if choosing_direction:
		if not swipe_started:
			return
		if is_redirecting:
			if is_instance_valid(preview_spirit):
				preview_spirit.set_facing(current_facing_dir)
				preview_spirit.toggle_range_indicator(false)
			choosing_direction = false
			is_redirecting = false
			swipe_started = false
			preview_spirit = null
			deselect_spirit()
			emit_signal("slowmo_requested", false)
		else:
			if is_instance_valid(preview_spirit):
				_confirm_deploy_direction(current_facing_dir)
		return

	if not dragging:
		return
	dragging = false
	var col := floori(mouse_pos.x / tile_size)
	var row := floori(mouse_pos.y / tile_size)
	var tile_key := "%d_%d" % [col, row]

	var spirit_data: SpiritData = battle_ref.get_spirit_data(drag_spirit_id)
	var col_out: bool = col < 0 or col >= battle_ref.grid_cols
	var row_out: bool = row < 0 or row >= battle_ref.grid_rows
	var out_of_grid: bool = col_out or row_out
	if spirit_data == null or out_of_grid:
		_cleanup_drag()
		emit_signal("slowmo_requested", false)
		return
	if (
		battle_ref.can_deploy_at(col, row, spirit_data.unit_type)
		and not battle_ref.occupied_tiles.has(tile_key)
		and int(battle_ref.cp) >= spirit_data.cp_cost
	):
		pending_deploy_data = spirit_data
		pending_deploy_tile = Vector2i(col, row)
		_cleanup_drag()
		_enter_direction_mode()
		return

	_cleanup_drag()
	emit_signal("slowmo_requested", false)


func _enter_direction_mode():
	choosing_direction = true
	is_redirecting = false
	swipe_started = false
	emit_signal("slowmo_requested", true)

	var tile_center := Vector2(
		pending_deploy_tile.x * tile_size + tile_size / 2.0,
		pending_deploy_tile.y * tile_size + tile_size / 2.0
	)
	swipe_start_pos = tile_center
	current_facing_dir = Vector2i(1, 0)

	battle_ref.focus_camera_on(tile_center, 1.18)

	preview_spirit = Node2D.new()
	preview_spirit.set_script(SPIRIT_SCRIPT)
	preview_spirit.position = tile_center
	preview_spirit.modulate = Color(1, 1, 1, 0.85)
	battle_ref.add_child(preview_spirit)
	preview_spirit.init(battle_ref, pending_deploy_data)
	preview_spirit.set_process(false)
	preview_spirit.set_facing(current_facing_dir)
	preview_spirit.toggle_range_indicator(false)


func _confirm_deploy_direction(dir: Vector2i):
	var spirit_data := pending_deploy_data
	var col := pending_deploy_tile.x
	var row := pending_deploy_tile.y
	var tile_key := "%d_%d" % [col, row]

	_exit_direction_mode()

	if spirit_data == null:
		return
	var cannot_afford: bool = int(battle_ref.cp) < spirit_data.cp_cost
	if battle_ref.occupied_tiles.has(tile_key) or cannot_afford:
		return

	var sid: String = spirit_data.id
	battle_ref.deduct_cp(spirit_data.cp_cost)

	var spirit := Node2D.new()
	spirit.set_script(SPIRIT_SCRIPT)
	spirit.position = Vector2(
		col * tile_size + tile_size / 2.0,
		row * tile_size + tile_size / 2.0
	)
	battle_ref.add_child(spirit)
	spirit.init(battle_ref, spirit_data)
	spirit.set_facing(dir)
	spirit.toggle_range_indicator(false)

	spirit.set_meta("spirit_id", sid)
	spirit.set_meta("tile_key", tile_key)

	emit_signal("spirit_deployed_successfully", spirit, tile_key, sid)


func cancel_direction_mode():
	if is_redirecting and is_instance_valid(preview_spirit):
		preview_spirit.set_facing(original_facing_dir)
	_exit_direction_mode()


func _exit_direction_mode():
	choosing_direction = false
	swipe_started = false
	pending_deploy_data = null
	pending_deploy_tile = Vector2i.ZERO

	if not is_redirecting:
		if is_instance_valid(preview_spirit):
			preview_spirit.queue_free()
	else:
		if is_instance_valid(preview_spirit):
			preview_spirit.toggle_range_indicator(false)
	preview_spirit = null
	is_redirecting = false

	if selected_spirit != null:
		deselect_spirit()
	else:
		battle_ref.reset_camera()
	emit_signal("slowmo_requested", false)


func _cleanup_drag():
	battle_ref.reset_tile_color(_last_highlighted_tile)
	_last_highlighted_tile = ""
	if is_instance_valid(drag_sprite):
		drag_sprite.queue_free()
		drag_sprite = null
	drag_spirit_id = ""


func _update_drag_tint(mouse_pos: Vector2):
	if drag_spirit_id == "" or not is_instance_valid(drag_sprite):
		return

	var spirit_data: SpiritData = battle_ref.get_spirit_data(drag_spirit_id)
	if spirit_data == null:
		return

	var col := floori(mouse_pos.x / tile_size)
	var row := floori(mouse_pos.y / tile_size)
	var tile_key := "%d_%d" % [col, row]

	if _last_highlighted_tile != "" and _last_highlighted_tile != tile_key:
		battle_ref.reset_tile_color(_last_highlighted_tile)

	var valid: bool = (
		battle_ref.can_deploy_at(col, row, spirit_data.unit_type)
		and not battle_ref.occupied_tiles.has(tile_key)
	)

	drag_sprite.modulate = Color(1, 1, 1, 0.85) if valid else Color(1, 0.35, 0.35, 0.78)

	var tile_rect = battle_ref.get_tile_node(tile_key)
	if tile_rect and is_instance_valid(tile_rect):
		tile_rect.color = Color(0.5, 1.0, 0.5, 0.85) if valid else Color(1.0, 0.3, 0.3, 0.70)
		_last_highlighted_tile = tile_key


func handle_arena_click(mouse_pos: Vector2) -> bool:
	var col := floori(mouse_pos.x / tile_size)
	var row := floori(mouse_pos.y / tile_size)
	var tile_key := "%d_%d" % [col, row]

	if battle_ref.occupied_tiles.has(tile_key):
		var target_spirit: Node2D = battle_ref.occupied_tiles[tile_key]
		if is_instance_valid(target_spirit):
			if selected_spirit == target_spirit:
				choosing_direction = true
				is_redirecting = true
				swipe_started = true
				swipe_start_pos = mouse_pos
				original_facing_dir = target_spirit.facing_dir
				current_facing_dir = target_spirit.facing_dir
				preview_spirit = target_spirit
				preview_spirit.toggle_range_indicator(true)
				emit_signal("spirit_selected_changed", null)
				emit_signal("slowmo_requested", true)
				battle_ref.focus_camera_on(target_spirit.position, 1.18)
				return true
			select_spirit(target_spirit)
			battle_ref.focus_camera_on(target_spirit.position, 1.18)
			return true

	deselect_spirit()
	return false


func select_spirit(spirit: Node2D):
	if selected_spirit != null and is_instance_valid(selected_spirit):
		if selected_spirit != spirit:
			selected_spirit.toggle_range_indicator(false)

	selected_spirit = spirit
	if is_instance_valid(selected_spirit):
		selected_spirit.toggle_range_indicator(true)
	emit_signal("spirit_selected_changed", selected_spirit)


func deselect_spirit():
	if selected_spirit != null and is_instance_valid(selected_spirit):
		selected_spirit.toggle_range_indicator(false)
	selected_spirit = null
	emit_signal("spirit_selected_changed", null)
	battle_ref.reset_camera()


func execute_retreat_selected():
	if selected_spirit == null or not is_instance_valid(selected_spirit):
		return
	var spirit := selected_spirit
	deselect_spirit()
	_retreat_spirit(spirit)


func execute_skill_selected():
	if selected_spirit == null or not is_instance_valid(selected_spirit):
		return
	var spirit := selected_spirit
	deselect_spirit()
	if spirit.has_method("trigger_skill"):
		spirit.trigger_skill()


func try_retreat_by_mouse(mouse_pos: Vector2):
	var col := floori(mouse_pos.x / tile_size)
	var row := floori(mouse_pos.y / tile_size)
	var tile_key := "%d_%d" % [col, row]

	if not battle_ref.occupied_tiles.has(tile_key):
		return

	var spirit: Node2D = battle_ref.occupied_tiles[tile_key]
	if not is_instance_valid(spirit):
		return

	if selected_spirit == spirit:
		deselect_spirit()
	_retreat_spirit(spirit)


func _retreat_spirit(spirit: Node2D):
	var sid: String = spirit.get_meta("spirit_id", "")
	var tile_key: String = spirit.get_meta("tile_key", "")

	if "blocking" in spirit:
		for enemy in spirit.blocking:
			if is_instance_valid(enemy):
				enemy.clear_blocked()

	spirit.queue_free()
	emit_signal("retreat_executed", sid, tile_key)


func cancel_all():
	if dragging:
		dragging = false
		_cleanup_drag()
	if choosing_direction:
		cancel_direction_mode()
	elif selected_spirit != null:
		deselect_spirit()
	else:
		battle_ref.reset_camera()
	emit_signal("slowmo_requested", false)