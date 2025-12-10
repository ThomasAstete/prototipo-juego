extends Node3D

# --- CONFIGURACIÓN ---
@export_group("Top Down Settings")
@export var top_down_rot = -55.0
@export var top_down_dist = 9.0

@export_group("Aim Settings")
@export var aim_rot = -10.0
@export var aim_dist = 2.5
@export var aim_h_offset : float = 0.5
@export var aim_v_offset : float = 0.0

@export_group("Control")
@export var mouse_sensitivity : float = 0.005
@export var lerp_speed : float = 8.0

@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D

@export_group("UI")
@export var crosshair_ui : Control # Arrastraremos aquí el nodo "MiraUI"
# Ya no necesitamos referencia al player para rotarlo

var is_aiming : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# CAMBIO IMPORTANTE:
		# Antes: player.rotate_y(...) -> Giraba al personaje
		# Ahora: rotate_y(...) -> Gira SOLO el pivote (la cámara orbita)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotación vertical (Solo si apuntamos o si quieres cámara libre total)
		# Si quieres poder mirar arriba/abajo siempre, quita el "if is_aiming"
		if is_aiming:
			rotation.x -= event.relative.y * mouse_sensitivity
			rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _process(delta):
	# Detectar input
	if Input.is_action_pressed("aim"):
		is_aiming = true
	else:
		is_aiming = false
	
	# --- CONTROLAR LA MIRA (NUEVO) ---
	if crosshair_ui:
		crosshair_ui.visible = is_aiming # Solo se ve si apuntamos
	# Detectar Click Derecho
	is_aiming = Input.is_action_pressed("aim")
		
	# --- INTERPOLACIÓN Y ZOOM ---
	if is_aiming:
		spring_arm.spring_length = lerp(spring_arm.spring_length, aim_dist, delta * lerp_speed)
		camera.h_offset = lerp(camera.h_offset, aim_h_offset, delta * lerp_speed)
		camera.v_offset = lerp(camera.v_offset, aim_v_offset, delta * lerp_speed)
	else:
		# Modo Top Down
		var target_rot_rad = deg_to_rad(top_down_rot)
		rotation.x = lerp_angle(rotation.x, target_rot_rad, delta * lerp_speed)
		spring_arm.spring_length = lerp(spring_arm.spring_length, top_down_dist, delta * lerp_speed)
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * lerp_speed)
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * lerp_speed)
