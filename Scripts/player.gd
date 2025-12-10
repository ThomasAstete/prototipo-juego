extends CharacterBody3D

# --- CONFIGURACIÓN ---
var llaves_colectadas : int = 0
@onready var contador_label = $CanvasLayer/ContadorUI # Ajusta la ruta si es necesario
@export_group("Movimiento")
@export var speed : float = 5.0
@export var rotation_speed : float = 10.0
@export var gravity : float = 20.0

@export_group("Ajustes Visuales")
@export var rotation_offset : float = 180.0 

@export_group("Interacción")
# Esta ruta debe ser correcta
@onready var interaction_ray = $CameraPivot/SpringArm3D/Camera3D/RayCast3D
# Necesitamos la referencia a la cámara para saber dónde está el centro de la pantalla
@onready var camera = $CameraPivot/SpringArm3D/Camera3D

# --- REFERENCIAS ---
@onready var camera_pivot = $CameraPivot
@onready var visuals = $Casual_Hoodie 

# Ajusta si es necesario
@onready var anim_player = $Casual_Hoodie/AnimationPlayer

func _physics_process(delta):
	# 1. GRAVEDAD
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- CORRECCIÓN DE PUNTERÍA (NUEVO) ---
	# Esto obliga al RayCast a apuntar EXACTAMENTE al centro de tu pantalla,
	# sin importar cuánto muevas la cámara con H_Offset.
	if camera and interaction_ray:
		# Calculamos el centro exacto de tu ventana de juego
		var center_screen = get_viewport().get_visible_rect().size / 2
		
		# Proyectamos un punto desde la cámara hacia el infinito pasando por el centro
		var ray_origin = camera.project_ray_origin(center_screen)
		var ray_normal = camera.project_ray_normal(center_screen)
		var ray_target = ray_origin + (ray_normal * 1000.0) # 1000 metros al frente
		
		# Forzamos al RayCast a mirar a ese punto
		interaction_ray.global_position = ray_origin
		interaction_ray.look_at(ray_target)


	# 2. INPUT
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 3. DIRECCIÓN
	var direction = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		var cam_basis = camera_pivot.global_transform.basis
		var cam_forward = -cam_basis.z
		var cam_right = cam_basis.x
		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()
		
		# W es adelante
		direction = (cam_forward * -input_dir.y) + (cam_right * input_dir.x)
		direction = direction.normalized()

	# 4. MOVER Y ANIMAR
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if anim_player:
			anim_player.play("Walk") 
			
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		if anim_player:
			anim_player.play("Idle")

	move_and_slide()

	# 5. ROTAR VISUALS
	if direction != Vector3.ZERO and not camera_pivot.is_aiming:
		var target_angle = atan2(-direction.x, -direction.z) + deg_to_rad(rotation_offset)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, rotation_speed * delta)
		
	elif camera_pivot.is_aiming:
		var target_angle = camera_pivot.global_rotation.y + deg_to_rad(rotation_offset)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, rotation_speed * delta)

	# 6. INTERACCIÓN
	if Input.is_action_just_pressed("interact"):
		check_interaction()

func check_interaction():
	# DEBUG: Verifica qué toca el rayo corregido
	if interaction_ray.is_colliding():
		var objeto = interaction_ray.get_collider()
		# print("Tocando: ", objeto.name) # Descomenta si necesitas probar
		
		if objeto.has_method("interactuar"):
			objeto.interactuar()
			agregar_llave()

func agregar_llave():
	llaves_colectadas += 1
	contador_label.text = "Llaves: " + str(llaves_colectadas)
	print("¡Tengo una llave más!")
	# Actualizamos el texto en pantalla
