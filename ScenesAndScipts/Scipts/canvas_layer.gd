extends CanvasLayer

func _ready():
	# (Opcional) Si quieres que empiece desactivado, descomenta la siguiente línea:
	visible = false
	pass

func _input(event):
	# Detectamos si es un evento de teclado, si se presionó la tecla, y si no es un "eco" (mantenerla apretada)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			# Invertimos la visibilidad: si es true pasa a false, y viceversa.
			visible = not visible
