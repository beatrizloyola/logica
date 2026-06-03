extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5

@export var mouse_sensitivity := 0.0025
@export var max_look_up := 80.0
@export var max_look_down := -80.0
@export var interact_distance := 4.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var is_paused := false
var is_reading := false
var pause_overlay: ColorRect
var pause_panel: Control

var ui_layer: CanvasLayer
var center_dot: ColorRect

var inventario = {
	"coletavel": 0
}


func _ready() -> void:
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	criar_ui()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			alternar_pause()
			return

	if is_paused or is_reading:
		return

	if event is InputEventMouseMotion:
		girar_camera(event.relative)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tentar_interagir()


func girar_camera(mouse_delta: Vector2) -> void:
	# Mouse esquerda/direita -> câmera esquerda/direita
	rotate_y(-mouse_delta.x * mouse_sensitivity)

	# Mouse cima/baixo -> câmera cima/baixo
	head.rotate_x(-mouse_delta.y * mouse_sensitivity)

	head.rotation.x = clamp(
		head.rotation.x,
		deg_to_rad(max_look_down),
		deg_to_rad(max_look_up)
	)


func tentar_interagir() -> void:
	var origem := camera.global_position
	var direcao := -camera.global_transform.basis.z
	var destino := origem + direcao * interact_distance

	var query := PhysicsRayQueryParameters3D.create(origem, destino)
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 0xFFFFFFFF

	var resultado := get_world_3d().direct_space_state.intersect_ray(query)

	if resultado.is_empty():
		print("Clique registrado, mas nenhum objeto foi atingido.")
		return

	var collider: Node = resultado["collider"]
	var interagivel := buscar_interagivel(collider)

	if interagivel == null:
		print("Objeto atingido, mas não é interagível: ", collider.name)
		return

	print("Interagindo com: ", interagivel.name)
	interagivel.interact(self)


func buscar_interagivel(node: Node) -> Node:
	var atual := node

	while atual != null:
		if atual.has_method("interact"):
			return atual

		atual = atual.get_parent()

	return null


func _physics_process(delta: float) -> void:
	if is_paused or is_reading:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	aplicar_gravidade(delta)
	processar_movimento()
	processar_pulo()

	move_and_slide()


func aplicar_gravidade(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func processar_movimento() -> void:
	var input_dir := Vector2.ZERO

	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	var direction := (
		global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func processar_pulo() -> void:
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY


func alternar_pause() -> void:
	is_paused = not is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_overlay.visible = true
		pause_panel.visible = true
		center_dot.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_overlay.visible = false
		pause_panel.visible = false
		center_dot.visible = true


func criar_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	center_dot = ColorRect.new()
	center_dot.color = Color.WHITE

	center_dot.anchor_left = 0.5
	center_dot.anchor_right = 0.5
	center_dot.anchor_top = 0.5
	center_dot.anchor_bottom = 0.5

	center_dot.offset_left = -2
	center_dot.offset_right = 2
	center_dot.offset_top = -2
	center_dot.offset_bottom = 2

	center_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ui_layer.add_child(center_dot)

	pause_overlay = ColorRect.new()
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.color = Color(0, 0, 0, 0.55)
	pause_overlay.visible = false
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(pause_overlay)

	pause_panel = CenterContainer.new()
	pause_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_panel.visible = false
	ui_layer.add_child(pause_panel)

	var fonte = load("res://assets/AnalogMono.ttf")

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	pause_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Pausado"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_font_override("font", fonte)
	title.modulate = Color(1, 1, 0.4)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	var btn_resume := _criar_opcao_pausa(vbox, "Voltar ao Jogo", fonte)
	btn_resume.pressed.connect(alternar_pause)

	var btn_quit := _criar_opcao_pausa(vbox, "Sair", fonte)
	btn_quit.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))

	btn_resume.grab_focus()


func _criar_opcao_pausa(parent: VBoxContainer, texto: String, fonte: Font) -> Button:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var arrow := Label.new()
	arrow.text = ">"
	arrow.add_theme_font_size_override("font_size", 36)
	arrow.add_theme_font_override("font", fonte)
	arrow.modulate = Color(1, 1, 0.4, 0)
	arrow.custom_minimum_size = Vector2(30, 0)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(arrow)

	var btn := Button.new()
	btn.text = texto
	btn.flat = true
	btn.custom_minimum_size = Vector2(260, 60)
	btn.add_theme_font_size_override("font_size", 36)
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


func adicionar_item(nome_do_item: String) -> void:
	if inventario.has(nome_do_item):
		inventario[nome_do_item] += 1
		print("Inventário atualizado: ", nome_do_item, " = ", inventario[nome_do_item])
	else:
		print("Item não existe no inventário: ", nome_do_item)


func set_reading(value: bool) -> void:
	is_reading = value
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		center_dot.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		center_dot.visible = true
