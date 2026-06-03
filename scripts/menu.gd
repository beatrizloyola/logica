extends Control


func _ready() -> void:
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
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "∉xit"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 80)
	title.modulate = Color(1, 1, 0.4)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 32)
	vbox.add_child(spacer)

	var start := Button.new()
	start.text = "Iniciar"
	start.custom_minimum_size = Vector2(220, 52)
	start.add_theme_font_size_override("font_size", 28)
	start.pressed.connect(_on_start)
	vbox.add_child(start)

	var quit := Button.new()
	quit.text = "Sair"
	quit.custom_minimum_size = Vector2(220, 52)
	quit.add_theme_font_size_override("font_size", 28)
	quit.pressed.connect(_on_quit)
	vbox.add_child(quit)


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/backrooms.tscn")


func _on_quit() -> void:
	get_tree().quit()
