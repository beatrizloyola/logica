extends Node

@export var items: Array[NoteItem] = []


func _ready() -> void:
	NoteReader.set_sequence(items)
