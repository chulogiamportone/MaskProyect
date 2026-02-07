extends Node3D

func interactuar(player_que_me_toco):
	print("Interactuando con cuchillo...")
	
	# Verificamos que el jugador tenga la función necesaria
	if player_que_me_toco.tiene_mascara:
		player_que_me_toco.animation_player.play("cur_arm")
		# Desaparecemos del mundo porque ya estamos en el inventario
		queue_free()
