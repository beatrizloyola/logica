extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var video := VideoStreamPlayer.new()
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	video.stream = load("res://assets/estaticaazul.ogv")
	video.expand = true
	video.loop = true
	add_child(video)
	video.play()

	var fonte = load("res://assets/AnalogMono.ttf")

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "∉xit"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_font_override("font", fonte)
	title.modulate = Color(1, 1, 0.4)
	vbox.add_child(title)

	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(sep)

	_add_credit(vbox, "Mapa", "Pedro Bedor, Daniel Donaire e Juan Riquelme", fonte)
	_add_credit(vbox, "Puzzles", "João Rafael, Arthur Vitorino e Juan Riquelme", fonte)
	_add_credit(vbox, "Scripting", "Victor Carraly e Beatriz Loyola", fonte)

	var sep2 := Control.new()
	sep2.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(sep2)

	var btn_restart := _criar_opcao(vbox, "Jogar Novamente", fonte)
	btn_restart.pressed.connect(_on_restart)

	var btn_quit := _criar_opcao(vbox, "Sair", fonte)
	btn_quit.pressed.connect(_on_quit)

	btn_restart.grab_focus()


func _add_credit(parent: VBoxContainer, role: String, names: String, fonte: Font) -> void:
	var role_label := Label.new()
	role_label.text = role
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	role_label.add_theme_font_size_override("font_size", 18)
	role_label.add_theme_font_override("font", fonte)
	role_label.modulate = Color(1, 1, 0.4)
	parent.add_child(role_label)

	var names_label := Label.new()
	names_label.text = names
	names_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	names_label.add_theme_font_size_override("font_size", 22)
	names_label.add_theme_font_override("font", fonte)
	parent.add_child(names_label)


func _criar_opcao(parent: VBoxContainer, texto: String, fonte: Font) -> Button:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var arrow := Label.new()
	arrow.text = ">"
	arrow.add_theme_font_size_override("font_size", 42)
	arrow.add_theme_font_override("font", fonte)
	arrow.modulate = Color(1, 1, 0.4, 0)
	arrow.custom_minimum_size = Vector2(30, 0)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(arrow)

	var btn := Button.new()
	btn.text = texto
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(280, 70)
	btn.add_theme_font_size_override("font_size", 42)
	btn.add_theme_font_override("font", fonte)

	for est in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(est, StyleBoxEmpty.new())

	btn.mouse_entered.connect(btn.grab_focus)

	btn.focus_entered.connect(func():
		arrow.modulate = Color(1, 1, 0.4, 1)
		for cor in ["font_color", "font_hover_color", "font_hover_pressed_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			btn.add_theme_color_override(cor, Color(1, 1, 0.4))
	)

	btn.focus_exited.connect(func():
		arrow.modulate = Color(1, 1, 0.4, 0)
		for cor in ["font_color", "font_hover_color", "font_hover_pressed_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			btn.remove_theme_color_override(cor)
	)

	hbox.add_child(btn)
	return btn


func _on_restart() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_quit() -> void:
	get_tree().quit()
