extends AudioStreamPlayer3D
@onready var character_body_3d: CharacterBody3D = $".."

# Llama a esta función cuando quieras iniciar el fade out
func fade_out_y_apagar(tiempo_duracion: float = 2.0):
	# Creamos el Tween
	var tween = create_tween()
	
	# 1. Bajamos el volumen a -80 decibelios (silencio absoluto)
	# tween_property(objeto, "propiedad", valor_final, duracion)
	tween.tween_property(self, "volume_db", -80.0, tiempo_duracion)
	
	# 2. Cuando termine la animación anterior, ejecutamos stop()
	tween.tween_callback(self.stop)
	#Texto_3
	character_body_3d.label_mision.text="Burn the candles, burn the mask and yourself."
	
	# (Opcional) Si quieres que al volver a dar play suene normal, 
	# puedes resetear el volumen justo después de apagarlo:
	# tween.tween_callback(func(): volume_db = 0.0)
