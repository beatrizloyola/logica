class_name Note
extends Node3D


func _ready() -> void:
	add_to_group("interactable")


func interact(_player) -> void:
	NoteReader.collect_next()
	queue_free()
