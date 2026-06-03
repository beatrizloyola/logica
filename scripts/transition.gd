extends CanvasLayer

var _rect: ColorRect
var _mat: ShaderMaterial
var _time: float = 0.0
var _busy := false


func _ready() -> void:
	layer = 100
	visible = false

	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_mat = ShaderMaterial.new()
	_mat.shader = _build_shader()
	_rect.material = _mat
	add_child(_rect)


func _process(delta: float) -> void:
	if visible:
		_time += delta
		_mat.set_shader_parameter("time_seed", _time)


func go_to(scene_path: String) -> void:
	if _busy:
		return
	_busy = true
	visible = true
	_mat.set_shader_parameter("opacity", 1.0)

	# Load in background thread so _process keeps running
	ResourceLoader.load_threaded_request(scene_path)

	var status := ResourceLoader.THREAD_LOAD_IN_PROGRESS
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(scene_path)

	var packed: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	get_tree().change_scene_to_packed(packed)

	await get_tree().process_frame
	await get_tree().process_frame

	var tween := create_tween()
	tween.tween_method(
		func(v: float): _mat.set_shader_parameter("opacity", v),
		1.0, 0.0, 0.8
	)
	await tween.finished

	visible = false
	_busy = false


func _build_shader() -> Shader:
	var s := Shader.new()
	s.code = """
shader_type canvas_item;

uniform float time_seed : hint_range(0.0, 10000.0) = 0.0;
uniform float opacity   : hint_range(0.0, 1.0)     = 1.0;

float rand(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	float t = floor(time_seed * 24.0); // ~24 fps flicker

	// Coarse "tube" grain
	vec2 coarse = floor(uv * vec2(80.0, 60.0));
	float grain = rand(coarse + vec2(t, t * 1.7));

	// Fine detail layer
	vec2 fine = floor(uv * vec2(320.0, 240.0));
	float detail = rand(fine + vec2(t * 0.9, t * 2.3)) * 0.25;

	float noise = grain * 0.75 + detail;

	// CRT horizontal scanlines
	float scanline = 0.8 + 0.2 * sin(uv.y * PI * 180.0);
	noise *= scanline;

	// Random horizontal glitch bars
	float bar_row = floor(uv.y * 40.0 + time_seed * 2.5);
	float glitch = step(0.93, rand(vec2(bar_row, t * 0.3)));
	noise += glitch * rand(vec2(uv.x * 80.0, bar_row)) * 0.6;

	// Slow vertical roll (loss of sync)
	float roll = fract(uv.y + time_seed * 0.07);
	float roll_band = smoothstep(0.0, 0.04, roll) * smoothstep(1.0, 0.96, roll);
	noise *= mix(0.3, 1.0, roll_band);

	// Vignette
	vec2 v = uv * 2.0 - 1.0;
	float vignette = 1.0 - dot(v, v) * 0.35;

	noise = clamp(noise * vignette, 0.0, 1.0);
	COLOR = vec4(vec3(noise), opacity);
}
"""
	return s
