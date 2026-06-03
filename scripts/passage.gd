class_name Passage
extends Node3D

@export var next_scene: String = ""
@export var wall_path: NodePath
@export var trigger_path: NodePath
@export var open_direction: Vector3 = Vector3(0, -1, 0)
@export var open_distance: float = 3.0
@export var open_duration: float = 1.5

var _wall: Node3D
var _trigger: Area3D
var _is_open := false


func _ready() -> void:
	if wall_path != NodePath():
		_wall = get_node_or_null(wall_path)
	if trigger_path != NodePath():
		_trigger = get_node_or_null(trigger_path)

	if _trigger != null:
		_trigger.body_entered.connect(_on_trigger_entered)
		_trigger.monitoring = false

	call_deferred("_connect_logic")


func _connect_logic() -> void:
	var logic_level = get_tree().get_first_node_in_group("logic_level")
	if logic_level != null:
		logic_level.solved.connect(open)


func open() -> void:
	if _is_open or _wall == null:
		return
	_is_open = true

	var tween := create_tween()
	tween.tween_property(
		_wall,
		"position",
		_wall.position + open_direction * open_distance,
		open_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if _trigger != null:
		tween.tween_callback(func(): _trigger.monitoring = true)


func _on_trigger_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and next_scene != "":
		Transition.go_to(next_scene)
