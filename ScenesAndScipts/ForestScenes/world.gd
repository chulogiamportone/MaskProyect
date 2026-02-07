extends Node3D
const MENU = preload("uid://dh123lpepp4qd")

var instancia
@onready var timer: Timer = $Timer
var unique:bool=false
func _ready() -> void:
	instancia = MENU.instantiate()
func _on_area_3d_body_exited(_body: Node3D) -> void:
	if !unique:
		unique=true
		instancia = MENU.instantiate()
		# 3. Añadirla al árbol de nodos como hija de este nodo
		self.get_parent().get_parent().add_child(instancia)
		print(self.get_parent().get_parent())
		self.get_parent().queue_free()
		timer.start()
	#self.get_parent().queue_free()


func _on_timer_timeout() -> void:
	get_tree().quit()
