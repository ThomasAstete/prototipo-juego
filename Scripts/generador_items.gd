extends Node3D

# --- CONFIGURACIÓN ---
@export_group("Configuración Generador")
@export var objeto_escena : PackedScene  # Aquí arrastraremos tu escena "Item_Llave.tscn"
@export var cantidad : int = 3           # Cuántos objetos quieres generar
@export var altura_spawn : float = 0.5   # Altura del suelo (para que no queden enterrados)

@export_group("Área de Spawn")
@export var area_x : float = 15.0        # Ancho del área donde pueden aparecer
@export var area_z : float = 15.0        # Largo del área donde pueden aparecer

func _ready():
	generar_objetos()

func generar_objetos():
	# Verificamos que hayamos asignado una escena, si no, daría error
	if objeto_escena == null:
		print("¡ERROR! No has asignado la escena del objeto en el Inspector.")
		return

	for i in range(cantidad):
		# 1. Crear una copia del objeto
		var nuevo_objeto = objeto_escena.instantiate()
		
		# 2. Añadirlo a la escena principal
		add_child(nuevo_objeto)
		
		# 3. Calcular una posición aleatoria
		# randf_range nos da un número decimal al azar entre A y B
		var random_x = randf_range(-area_x / 2, area_x / 2)
		var random_z = randf_range(-area_z / 2, area_z / 2)
		
		# 4. Mover el objeto a esa posición
		# Usamos la posición de este nodo generador como centro + el azar
		nuevo_objeto.position = Vector3(random_x, altura_spawn, random_z)
