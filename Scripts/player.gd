extends CharacterBody3D

# --- CONFIGURACIÓN ---
@export var speed : float = 5.0
@export var rotation_speed : float = 12.0
@export var gravity : float = 20.0

# --- REFERENCIAS ---
# Asegúrate de que estos nombres sean IDÉNTICOS a los de tu panel de escena
@onready var camera_pivot = $CameraPivot
@onready var visuals = $Casual_Hoodie  

func _physics_process(delta):
	# 1. Aplicar Gravedad (Importante para evitar comportamientos raros en el suelo)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Obtener Inputs
	# Usamos "ui_..." que ya vienen configurados por defecto (Flechas o WASD)
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	# 3. Calcular dirección relativa a la CÁMARA
	# Esto es vital: "Arriba" debe ser "Hacia el fondo de la pantalla", no "Norte"
	var direction = Vector3.ZERO
	
	if input_dir != Vector2.ZERO:
		# Obtenemos hacia dónde mira la cámara (solo en el eje Y, horizontal)
		var cam_rot_y = camera_pivot.global_transform.basis.get_euler().y
		
		# Convertimos el input 2D en dirección 3D
		direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_rot_y).normalized()

	# 4. Movimiento y Rotación
	if direction:
		# Asignar velocidad
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Rotar el modelo (Visuals) hacia donde camina
		# Usamos atan2 para obtener el ángulo del movimiento
		var target_rotation = atan2(direction.x, direction.z)
		# Usamos lerp_angle para suavizar el giro
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_rotation, rotation_speed * delta)
	else:
		# Frenado suave (fricción)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
