extends Area3D

# Cantidad de llaves necesarias para ganar
@export var llaves_necesarias : int = 3
@onready var sonido_victoria = $SonidoVictoria

func _ready():
	# Esto conecta automáticamente la señal de "alguien entró"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 1. Verificamos si quien entró es el Player (por su nombre)
	if body.name == "Player":
		print("El jugador tocó la puerta.")
		
		# 2. Verificamos si tiene las llaves (accedemos a su variable)
		# Asegúrate de que en player.gd la variable se llame 'llaves_colectadas'
		if body.get("llaves_colectadas") != null:
			if body.llaves_colectadas >= llaves_necesarias:
				ganar_partida(body)
			else:
				print("Puerta cerrada. Tienes ", body.llaves_colectadas, " / ", llaves_necesarias)
		else:
			print("Error: No encuentro la variable 'llaves_colectadas' en el Player")

func ganar_partida(player):
	print("¡VICTORIA!")
	
	# 1. Mostrar el cartel de 'ESCAPASTE'
	var cartel = player.get_node_or_null("CanvasLayer/MensajeVictoria")
	if cartel:
		cartel.visible = true
	
	if sonido_victoria:
		# 1. Empezar en el segundo 0.87
		sonido_victoria.play(0.87)
		
		# 2. Calcular cuánto debe sonar (2.39 - 0.87 = 1.52)
		var duracion = 1.52
		
		# 3. Crear el temporizador para detenerlo
		get_tree().create_timer(duracion).timeout.connect(sonido_victoria.stop)
