extends Node3D
func interactuar(player_que_me_toco):
	print("Interactuando con brazo...")
	
	# Verificamos que el jugador tenga la función necesaria
	if player_que_me_toco.tiene_mascara:
		if player_que_me_toco.has_method("equipar_brazo"):
			player_que_me_toco.equipar_brazo()
			player_que_me_toco.final.play(34)
		# Desaparecemos del mundo porque ya estamos en el inventario
			queue_free()
