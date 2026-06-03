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
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "E X I T"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 120)
	title.add_theme_font_override("font", fonte)
	title.modulate = Color(1, 1, 0.4)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 48)
	vbox.add_child(spacer)

	var btn_start := _criar_opcao(vbox, "Iniciar", fonte)
	btn_start.pressed.connect(_on_start)

	var btn_quit := _criar_opcao(vbox, "Sair", fonte)
	btn_quit.pressed.connect(_on_quit)

	btn_start.grab_focus()


func _criar_opcao(parent: VBoxContainer, texto: String, fonte: Font) -> Button:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var arrow := Label.new()
	arrow.text = ">"
	arrow.add_theme_font_size_override("font_size", 42)
	arrow.add_theme_font_override("font", fonte)
	arrow.modulate = Color(1, 1, 0.4, 0)  # amarelo, mas invisível por padrão
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

	# Remover fundo e borda de todos os estados
	for est in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(est, StyleBoxEmpty.new())

	# Hover do mouse sincroniza com foco do teclado
	btn.mouse_entered.connect(btn.grab_focus)

	# Quando ganha foco: mostra seta e amarela o texto
	btn.focus_entered.connect(func():
		arrow.modulate = Color(1, 1, 0.4, 1)
		for cor in ["font_color", "font_hover_color", "font_hover_pressed_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			btn.add_theme_color_override(cor, Color(1, 1, 0.4))
	)

	# Quando perde foco: esconde seta e volta texto para branco
	btn.focus_exited.connect(func():
		arrow.modulate = Color(1, 1, 0.4, 0)
		for cor in ["font_color", "font_hover_color", "font_hover_pressed_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			btn.remove_theme_color_override(cor)
	)

	hbox.add_child(btn)
	return btn


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/backrooms.tscn")


func _on_quit() -> void:
	get_tree().quit()
