class_name LevelHUD
extends CanvasLayer

@export var level_id: String = "tutorial"
@export var target_value: bool = true

var _label: Label
var _note_found := false
var _discovered_vars: Dictionary = {}
var _all_vars: Dictionary = {}
var _solved := false


func _ready() -> void:
	_label = Label.new()
	_label.anchor_left = 0.0
	_label.anchor_right = 0.0
	_label.anchor_top = 0.0
	_label.anchor_bottom = 0.0
	_label.offset_left = 16
	_label.offset_top = 16
	_label.add_theme_font_size_override("font_size", 20)
	_label.modulate = Color(1.0, 1.0, 0.4)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	NoteReader.note_collected.connect(_on_note_collected)

	var logic_level = get_tree().get_first_node_in_group("logic_level")
	if logic_level != null:
		logic_level.expression_updated.connect(_on_expression_updated)
		logic_level.solved.connect(_on_solved)

	call_deferred("_connect_switches")


func _connect_switches() -> void:
	for switch in get_tree().get_nodes_in_group("interactable"):
		if switch.has_signal("state_changed"):
			switch.state_changed.connect(_on_switch_interacted)


func _on_switch_interacted(symbol: String, value: bool) -> void:
	_discovered_vars[symbol] = value
	_update_display()


func _on_note_collected() -> void:
	_note_found = true
	_update_display()


func _on_expression_updated(vars: Dictionary, _result: bool) -> void:
	_all_vars = vars
	_update_display()


func _on_solved() -> void:
	_solved = true
	_label.modulate = Color(0.4, 1.0, 0.4)
	_update_display()


func _update_display() -> void:
	if _discovered_vars.is_empty() and not _note_found:
		_label.text = ""
		return

	var lines := ""

	if not _discovered_vars.is_empty():
		var vars_line := ""
		var sorted_keys := _discovered_vars.keys()
		sorted_keys.sort()
		for symbol in sorted_keys:
			vars_line += symbol + "=" + ("V" if _discovered_vars[symbol] else "F") + "  "
		lines += vars_line.strip_edges()

	if _note_found:
		var expr := LogicEvaluator.get_expression_text(level_id)
		var target_str := "V" if target_value else "F"
		if _solved:
			lines += "\n" + expr + " = " + target_str + " ✓"
		else:
			lines += "\n" + expr + " = ?  (meta: " + target_str + ")"

	_label.text = lines
