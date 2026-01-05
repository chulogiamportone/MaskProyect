extends Camera3D

# Arrastra aquí tu nodo del Player desde el árbol
@export var player_target: Node3D 


func _process(_delta):
	if player_target:
		# Copiar posición + el offset
		global_position = player_target.global_position
		global_position.y=60
		
