class_name LogicLevel
extends Node

signal expression_updated(vars: Dictionary, result: bool)
signal solved

@export var level_id: String = "tutorial"
@export var target_value: bool = true

var vars: Dictionary = {}
var _discovered: Dictionary = {}
var _already_solved := false
var _note_found := false


func _ready() -> void:
	add_to_group("logic_level")
	NoteReader.note_collected.connect(_on_note_collected)
	call_deferred("_setup")


func _setup() -> void:
	for switch in get_tree().get_nodes_in_group("interactable"):
		if switch.has_signal("state_changed"):
			switch.state_changed.connect(_on_state_changed)
			vars[switch.get_logic_symbol()] = switch.get_logic_value()
	_check()


func _on_note_collected() -> void:
	_note_found = true
	_check()


func _on_state_changed(symbol: String, value: bool) -> void:
	vars[symbol] = value
	_discovered[symbol] = true
	_check()


func _check() -> void:
	var result := LogicEvaluator.evaluate(level_id, vars)
	expression_updated.emit(vars, result)
	var all_discovered := _discovered.size() == vars.size()

	if result == target_value and _note_found and all_discovered and not _already_solved:
		_already_solved = true
		solved.emit()
