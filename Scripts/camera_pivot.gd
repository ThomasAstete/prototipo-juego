extends Node3D

# --- CONFIGURACIÓN ---
@export_group("Top Down Settings")
@export var top_down_rot = -55.0
@export var top_down_dist = 9.0

@export_group("Aim Settings")
# Ya no necesitamos "Aim Rot" fijo, porque tú controlarás la altura con el mouse
@export var aim_dist = 1.5
@export var aim_h_offset : float = 1.3 # Personaje a la izquierda
@export var aim_v_offset : float = 0.3 # Cámara sobre el hombro

@export_group("UI")
@export var crosshair_ui : Control

@export_group("Control")
@export var mouse_sensitivity : float = 0.005
@export var lerp_speed : float = 8.0

@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D

var is_aiming : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# 1. Rotación Horizontal (Siempre libre)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotación Vertical (SOLO AL APUNTAR)
		if is_aiming:
			# Permitimos mover el mouse arriba/abajo
			rotation.x -= event.relative.y * mouse_sensitivity
			
			# --- AQUÍ ESTÁ EL TRUCO (CLAMP) ---
			# Limitamos hasta dónde puedes bajar y subir la cabeza.
			# -70 grados: Mirar casi a tus propios pies (para ver items).
			#  15 grados: Mirar un poco hacia arriba (para enemigos altos).
			rotation.x = clamp(rotation.x, deg_to_rad(-70), deg_to_rad(15))

func _process(delta):
	# Detectar Input
	if Input.is_action_pressed("aim"):
		is_aiming = true
	else:
		is_aiming = false
	
	# Control UI
	if crosshair_ui:
		crosshair_ui.visible = is_aiming

	# --- INTERPOLACIÓN ---
	if is_aiming:
		# MODO APUNTAR
		# Nota: YA NO tocamos 'rotation.x' aquí, porque lo controla tu mouse arriba.
		
		# Solo suavizamos el Zoom y el movimiento al hombro
		spring_arm.spring_length = lerp(spring_arm.spring_length, aim_dist, delta * lerp_speed)
		camera.h_offset = lerp(camera.h_offset, aim_h_offset, delta * lerp_speed)
		camera.v_offset = lerp(camera.v_offset, aim_v_offset, delta * lerp_speed)
		
	else:
		# MODO TOP DOWN (Aquí sí forzamos la vista aérea)
		var target_rot_top = deg_to_rad(top_down_rot)
		rotation.x = lerp_angle(rotation.x, target_rot_top, delta * lerp_speed)
		
		spring_arm.spring_length = lerp(spring_arm.spring_length, top_down_dist, delta * lerp_speed)
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * lerp_speed)
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * lerp_speed)
