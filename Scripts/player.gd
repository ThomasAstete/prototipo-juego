extends CharacterBody3D

# --- CONFIGURACIÓN ---
@export_group("Movimiento")
@export var speed : float = 5.0
@export var rotation_speed : float = 10.0
@export var gravity : float = 20.0

@export_group("Ajustes Visuales")
@export var rotation_offset : float = 180.0 

@export_group("Interacción")
@onready var interaction_ray = $CameraPivot/SpringArm3D/Camera3D/RayCast3D

# --- REFERENCIAS ---
@onready var camera_pivot = $CameraPivot
@onready var visuals = $Casual_Hoodie 

# IMPORTANTE: Ajusta la ruta si tu AnimationPlayer está más adentro
# Si activaste "Hijos Editables", arrastra el nodo AnimationPlayer aquí para obtener la ruta correcta
@onready var anim_player = $Casual_Hoodie/AnimationPlayer

func _physics_process(delta):
	# 1. GRAVEDAD
	if not is_on_floor():
		velocity.y -= gravity * delta

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

	# 4. MOVER Y ANIMAR (MODIFICADO)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# --- AQUÍ ACTIVAMOS LA ANIMACIÓN DE CAMINAR ---
		# Cambia "Walk" por el nombre exacto que viste en el AnimationPlayer
		if anim_player:
			anim_player.play("Walk") 
			
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		# --- AQUÍ ACTIVAMOS LA ANIMACIÓN DE ESTAR QUIETO ---
		# Cambia "Idle" por el nombre exacto
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
	if interaction_ray.is_colliding():
		var objeto = interaction_ray.get_collider()
		if objeto.has_method("interactuar"):
			objeto.interactuar()
