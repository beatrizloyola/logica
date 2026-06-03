extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.019, 0.019, 0.019)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "∉xit"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.modulate = Color(1, 1, 0.4)
	vbox.add_child(title)

	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(sep)

	_add_credit(vbox, "Mapa", "Pedro Bedor, Daniel Donaire e Juan Riquelme")
	_add_credit(vbox, "Puzzles", "João Rafael, Arthur Vitorino e Juan Riquelme")
	_add_credit(vbox, "Scripting", "Victor Carraly e Beatriz Loyola")

	var sep2 := Control.new()
	sep2.custom_minimum_size = Vector2(0, 32)
	vbox.add_child(sep2)

	var restart := Button.new()
	restart.text = "Jogar Novamente"
	restart.custom_minimum_size = Vector2(260, 52)
	restart.add_theme_font_size_override("font_size", 26)
	restart.pressed.connect(_on_restart)
	vbox.add_child(restart)

	var quit := Button.new()
	quit.text = "Sair"
	quit.custom_minimum_size = Vector2(260, 52)
	quit.add_theme_font_size_override("font_size", 26)
	quit.pressed.connect(_on_quit)
	vbox.add_child(quit)


func _add_credit(parent: VBoxContainer, role: String, names: String) -> void:
	var role_label := Label.new()
	role_label.text = role
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.add_theme_font_size_override("font_size", 18)
	role_label.modulate = Color(1, 1, 0.4)
	parent.add_child(role_label)

	var names_label := Label.new()
	names_label.text = names
	names_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	names_label.add_theme_font_size_override("font_size", 22)
	parent.add_child(names_label)


func _on_restart() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_quit() -> void:
	get_tree().quit()
