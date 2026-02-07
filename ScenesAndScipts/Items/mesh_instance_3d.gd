extends MeshInstance3D

@onready var static_body = $StaticBody3D
var mdt = MeshDataTool.new()

func _ready():
	# 1. Configurar la malla para ser editable (Gráficos)
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(mesh, 0)
	surface_tool.generate_normals() # Para que se vea bien
	var array_mesh = surface_tool.commit()
	
	mdt.create_from_surface(array_mesh, 0)
	mesh = array_mesh
	
	# 2. Configurar Material
	if get_surface_override_material(0) == null:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.4, 0.3, 0.2)
		set_surface_override_material(0, mat)
		
	# --- CAMBIO IMPORTANTE ---
	# Comentamos esta línea. NO tocamos la física al inicio.
	# Confiamos en la colisión que creaste en el editor (Paso 1).
	# actualizar_colision() <--- PONLE UN # AL PRINCIPIO O BÓRRALA
	
	print("--- INICIO ---")
	print("Vértices: ", mdt.get_vertex_count())
	print("Física inicial: Usando la del editor.")

func cavar(posicion_golpe: Vector3, radio: float, cantidad_a_bajar: float):
	var local_pos = to_local(posicion_golpe)
	var hubo_cambios = false
	
	# --- FASE 1: Edición de vértices ---
	for i in range(mdt.get_vertex_count()):
		var vertice = mdt.get_vertex(i)
		# Usamos distancia 2D (plano XZ)
		var dist_xz = Vector2(vertice.x, vertice.z).distance_to(Vector2(local_pos.x, local_pos.z))
		
		if dist_xz < radio:
			var fuerza = 1.0 - (dist_xz / radio)
			vertice.y -= fuerza * cantidad_a_bajar
			
			# Tope de profundidad para no romper el juego (-3 metros)
			if vertice.y < -3.0: vertice.y = -3.0
			
			mdt.set_vertex(i, vertice)
			hubo_cambios = true
	
	if hubo_cambios:
		# --- FASE 2: Reconstrucción Visual (Aquí fallaba antes) ---
		
		# 1. Sacamos la geometría cruda del MDT a una malla temporal
		var mesh_temp = ArrayMesh.new()
		mdt.commit_to_surface(mesh_temp)
		
		# 2. Usamos SurfaceTool para recalcular luces (Normales)
		var st = SurfaceTool.new()
		st.create_from(mesh_temp, 0)
		st.generate_normals() # <--- ¡ESTO HACE QUE SE VEAN LAS SOMBRAS!
		
		# 3. Obtenemos la malla final pulida
		var mesh_final = st.commit()
		
		# 4. Asignamos visualmente
		mesh = mesh_final
		
		# 5. Recargamos el MDT para la próxima vez (Vital para no perder datos)
		mdt.create_from_surface(mesh_final, 0)
		
		# --- FASE 3: Actualización Física Segura ---
		actualizar_colision()

func actualizar_colision():
	# 1. Obtenemos geometría
	var caras = mesh.get_faces()
	if caras.size() == 0: return

	# 2. Creamos el cuerpo nuevo
	var nuevo_body = StaticBody3D.new()
	nuevo_body.name = "Body_" + str(Time.get_ticks_msec())
	
	# Copiamos solo las capas de colisión (para que el player lo detecte)
	nuevo_body.collision_layer = static_body.collision_layer
	nuevo_body.collision_mask = static_body.collision_mask
	
	# --- CORRECCIÓN DEFINITIVA DE POSICIÓN ---
	# Forzamos que la posición sea (0,0,0) y la rotación 0 relativas al padre.
	# Esto alinea los vértices de la colisión perfectamente con los de la malla visual.
	nuevo_body.transform = Transform3D.IDENTITY 
	# -----------------------------------------
	
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(caras)
	
	var col_shape = CollisionShape3D.new()
	col_shape.shape = shape
	nuevo_body.add_child(col_shape)
	
	add_child(nuevo_body)
	print("Colisión regenerada en posición 0,0,0 relativa.")

	# 3. Espera de seguridad (para no caer)
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 4. Borrado del viejo
	if is_instance_valid(static_body):
		static_body.queue_free()
	
	static_body = nuevo_body
