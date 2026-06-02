extends Node3D

signal state_changed(symbol: String, value: bool)

@export var symbol := "P"
@export var is_on := false

@export var moving_part_path: NodePath
@export var object_visible_when_on_path: NodePath

@export var off_rotation_degrees := Vector3.ZERO
@export var on_rotation_degrees := Vector3(0, 0, 45)

var moving_part: Node3D
var object_visible_when_on: Node


func _ready() -> void:
	add_to_group("interactable")

	if moving_part_path != NodePath():
		moving_part = get_node_or_null(moving_part_path)

	if object_visible_when_on_path != NodePath():
		object_visible_when_on = get_node_or_null(object_visible_when_on_path)

	atualizar_visual()


func interact(player) -> void:
	is_on = not is_on

	print(symbol, " = ", "V" if is_on else "F")

	atualizar_visual()
	state_changed.emit(symbol, is_on)


func atualizar_visual() -> void:
	if moving_part != null:
		moving_part.rotation_degrees = on_rotation_degrees if is_on else off_rotation_degrees

	if object_visible_when_on != null:
		object_visible_when_on.visible = is_on


func get_logic_symbol() -> String:
	return symbol


func get_logic_value() -> bool:
	return is_on