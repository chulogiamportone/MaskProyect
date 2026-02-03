extends Node3D
@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@onready var inicio: Control = $Object/Inicio


func _ready():
	# Asignamos los nodos de ESTA escena a las variables del Autoload
	AutoLoad.inicio = inicio
	AutoLoad.character_body_3d = character_body_3d
