extends Node3D


# Asigna aquí el MeshInstance3D que tiene el material (la "pantalla")

@onready var mesh_pantalla: MeshInstance3D = $Monitor

var indice_actual: int = 0
var lista_viewports: Array[Node] = []

func _ready() -> void:
	# OPTIMIZACIÓN: Obtenemos la lista una sola vez al inicio, no en cada frame.
	lista_viewports = get_tree().get_nodes_in_group("Viewports")
	
	# Opcional: Cargar el primero al iniciar
	if lista_viewports.size() > 0:
		cambiar_textura(lista_viewports[0])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if lista_viewports.is_empty():
			return # Evita errores si no hay viewports en el grupo

		# 1. Aumentamos el índice
		indice_actual += 1
		
		# 2. Usamos módulo (%) para que si el índice supera el tamaño, vuelva a 0
		# Ejemplo: si hay 3 viewports y el índice llega a 3, 3 % 3 = 0.
		indice_actual = indice_actual % lista_viewports.size()
		
		# 3. Obtenemos el siguiente viewport
		var viewport_seleccionado = lista_viewports[indice_actual]
		
		# 4. Llamamos a la función para cambiar la textura
		cambiar_textura(viewport_seleccionado)

func cambiar_textura(viewport: SubViewport) -> void:
	# Obtenemos la textura del viewport
	var textura_nueva = viewport.get_texture()
	
	# Asignamos la textura al material del mesh.
	# Asumimos que es un StandardMaterial3D en la superficie 0 o en override
	var material = mesh_pantalla.get_active_material(0)
	if material:
		material.albedo_texture = textura_nueva
