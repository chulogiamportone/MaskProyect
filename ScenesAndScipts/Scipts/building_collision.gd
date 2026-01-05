extends MeshInstance3D

func _ready():
	# Esto busca la geometría de tu ArrayMesh y crea la colisión
	create_trimesh_collision()
