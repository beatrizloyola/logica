extends CanvasLayer

signal note_collected

var _bg: ColorRect
var _paper: ColorRect
var _image: TextureRect
var _text_label: Label
var _counter_label: Label

var _sequence: Array[NoteItem] = []
var _collected: Array[NoteItem] = []
var _current_index: int = 0
var _is_showing: bool = false


func _ready() -> void:
	layer = 50
	visible = false
	_build_ui()


func _build_ui() -> void:
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0, 0, 0, 0.45)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	# Paper background for text notes
	_paper = ColorRect.new()
	_paper.anchor_left   = 0.175
	_paper.anchor_right  = 0.825
	_paper.anchor_top    = 0.1
	_paper.anchor_bottom = 0.88
	_paper.color = Color(0.95, 0.92, 0.85)
	_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_paper)

	_image = TextureRect.new()
	_image.anchor_left   = 0.175
	_image.anchor_right  = 0.825
	_image.anchor_top    = 0.1
	_image.anchor_bottom = 0.88
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_image)

	_text_label = Label.new()
	_text_label.anchor_left   = 0.175
	_text_label.anchor_right  = 0.825
	_text_label.anchor_top    = 0.1
	_text_label.anchor_bottom = 0.88
	_text_label.offset_left   = 40
	_text_label.offset_right  = -40
	_text_label.offset_top    = 40
	_text_label.offset_bottom = -40
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.add_theme_font_size_override("font_size", 28)
	_text_label.modulate = Color(0.1, 0.1, 0.1)
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text_label)

	_counter_label = Label.new()
	_counter_label.anchor_left   = 0.0
	_counter_label.anchor_right  = 1.0
	_counter_label.anchor_top    = 0.89
	_counter_label.anchor_bottom = 0.96
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counter_label.add_theme_font_size_override("font_size", 16)
	_counter_label.modulate = Color(1, 1, 1, 0.75)
	_counter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_counter_label)


func set_sequence(items: Array[NoteItem]) -> void:
	_sequence = items
	_collected.clear()


func collect_next() -> void:
	if _collected.size() >= _sequence.size():
		return
	var item := _sequence[_collected.size()]
	_collected.append(item)
	if item.is_tip:
		note_collected.emit()
	_current_index = _collected.size() - 1
	_set_visible(true)
	_show_current()


func _input(event: InputEvent) -> void:
	if _collected.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_TAB:
			_on_tab()


func _on_tab() -> void:
	if not _is_showing:
		_current_index = 0
		_set_visible(true)
		_show_current()
	else:
		_current_index += 1
		if _current_index >= _collected.size():
			_set_visible(false)
		else:
			_show_current()


func _show_current() -> void:
	var item: NoteItem = _collected[_current_index]
	var has_texture: bool = item.texture != null

	_paper.visible = not has_texture
	_image.visible = has_texture
	_text_label.visible = not has_texture

	if has_texture:
		_image.texture = item.texture
	else:
		_text_label.text = item.text

	var total: int = _collected.size()
	var current: int = _current_index + 1
	if current < total:
		_counter_label.text = str(current) + "/" + str(total) + "   [TAB] próximo"
	else:
		_counter_label.text = str(current) + "/" + str(total) + "   [TAB] fechar"


func _set_visible(value: bool) -> void:
	_is_showing = value
	visible = value

	var hud = get_tree().get_first_node_in_group("level_hud")
	if hud:
		hud.visible = not value

	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_reading"):
		player.set_reading(value)
