extends Control
@onready var credits: TextureRect = $Credits

const scene = preload("res://ScenesAndScipts/Forest.tscn")



func _on_button_pressed() -> void:
	credits.visible=false


func _on_play_pressed() -> void:
	# 2. Crear una instancia de esa escena (un objeto real)
	var instancia = scene.instantiate()
	
	# 3. Añadirla al árbol de nodos como hija de este nodo
	get_parent().add_child(instancia)
	self.queue_free()



func _on_credits_pressed() -> void:
	credits.visible=true


func _on_exit_pressed() -> void:
	get_tree().quit()
