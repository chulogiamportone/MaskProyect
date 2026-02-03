extends AudioStreamPlayer3D

# Ejemplo: reproducir desde el segundo 5.0 hasta el 10.0
func reproducir_segmento(inicio: float=28.9, fin: float=29.2):
	# 1. Iniciamos el audio primero (necesario para que el seek funcione bien)
	
	play(inicio)

	
	# 3. Calculamos cuánto debe durar
	var duracion = fin - inicio
	
	# 4. Esperamos ese tiempo
	await get_tree().create_timer(duracion).timeout
	
	# 5. Detenemos el audio
	stop()
