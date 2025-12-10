extends StaticBody3D

func interactuar():
	print("¡Recogiste una llave!")
	# Aquí podrías sumar puntos, agregar al inventario, etc.
	# Por ahora, simplemente la haremos desaparecer:
	queue_free()
