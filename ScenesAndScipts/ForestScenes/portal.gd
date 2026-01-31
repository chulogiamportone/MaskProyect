extends Node

# Precargamos la escena que tiene la cámara
var escena_camara = preload("res://ScenesAndScipts/ForestScenes/inferno.tscn")

func _ready():
	# 1. Crear la instancia
	var instancia = escena_camara.instantiate()
	
	# 2. Añadirla como hija del SubViewport
	# Asumiendo que la ruta es la correcta:
	$".".add_child(instancia)
