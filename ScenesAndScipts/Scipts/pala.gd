extends RigidBody3D

func interactuar(player_que_me_toco):
	print("Interactuando con pala...")
	
	# Verificamos que el jugador tenga la función necesaria
	if player_que_me_toco.has_method("equipar_pala"):
		player_que_me_toco.equipar_pala()
		
		# Desaparecemos del mundo porque ya estamos en el inventario
		queue_free()
