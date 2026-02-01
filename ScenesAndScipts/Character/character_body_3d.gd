extends CharacterBody3D

# --- CONFIGURACIÓN ---
@export var WALKING_SPEED = 5.0
@export var RUNNING_SPEED = 9.0
@export var CROUCH_SPEED = 3.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.003
@export var mask_canvas_layer:CanvasLayer
var mask_visible:Array[Node]
# Variables de gravedad (obtenidas de la configuración del proyecto)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Referencias a nodos hijos
@onready var head = $Camera3D
@onready var collision_shape = $CollisionShape3D

# --- NUEVO: Referencia al AnimationPlayer ---
# El nodo characterMedium es el nombre de la instancia en tu player.tscn [cite: 9]
@onready var anim_player = $characterMedium/AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_mask_active:bool=false
# Variables para agacharse
var default_height = 1.7 
var crouch_height = 1.0  
var crouch_speed_transition = 10.0 

@onready var interaction_ray = $Camera3D/RayCast3D 

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mask_visible=get_tree().get_nodes_in_group("mask_visible")
	interaction_ray.add_exception(self)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			intentar_cavar()

func _physics_process(delta):
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Lógica de Agacharse (Crouch)
	var current_speed = WALKING_SPEED
	
	if Input.is_action_just_pressed("action") and !is_mask_active:
		is_mask_active=true
		
		animation_player.play("mask_move")
		
	else:
		if Input.is_action_just_pressed("action") and is_mask_active:
			mask_canvas_layer.visible=false
			is_mask_active=false
			for object in mask_visible:
				object.visible=false
			animation_player.play_backwards("mask_move")
	
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		head.position.y = lerp(head.position.y, crouch_height, delta * crouch_speed_transition)
	else:
		if Input.is_action_pressed("sprint"):
			current_speed = RUNNING_SPEED
		head.position.y = lerp(head.position.y, default_height, delta * crouch_speed_transition)

	# 4. Movimiento Horizontal (WASD)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# 5. Aplicar movimiento
	move_and_slide()

	# --- NUEVO: Actualizar Animaciones ---
	# Llamamos a la función para decidir qué animación mostrar
	update_animations(input_dir)

	# Tecla de escape para liberar el mouse
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- NUEVA FUNCIÓN: Lógica de Animación ---
func update_animations(input_dir: Vector2):
	# Nombres de animaciones basados en tus librerías 
	# NOTA: Verifica los nombres exactos en la pestaña "Animation" de Godot.
	# Según tu archivo, tienes las librerías "animation", "jump" y "run".
	
	# La transición suave (blend) de 0.2 segundos ayuda a que no se vea cortado.
	var blend_time = 0.2

	if not is_on_floor():
		# Estás en el aire
		anim_player.play("jump/Root|Jump", blend_time) # Asumiendo nombre "Jump" en librería "jump"
		return

	# Si estamos en el suelo...
	if input_dir == Vector2.ZERO:
		# Estamos quietos
		# Tu archivo indica que el autoplay es "animation/Root|Idle" 
		anim_player.play("animation/Root|Idle", blend_time)
	else:
		# Nos estamos moviendo
		if Input.is_action_pressed("sprint"):
			anim_player.play("run/Root|Run", blend_time) # Asumiendo nombre "Run" en librería "run"
		elif Input.is_action_pressed("crouch"):
			# Si no tienes animación de agachado, usa Walk o Idle
			anim_player.play("run/Root|Run", blend_time) 
		else:
			# Caminando normal
			anim_player.play("run/Root|Run", blend_time) # Asumiendo nombre "Walk" en librería "animation"


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if is_mask_active:
		mask_canvas_layer.visible=true
		for object in mask_visible:
			object.visible=true


func intentar_cavar():
	print("--- INTENTO DE CAVAR ---")
	
	# 1. Forzamos al raycast a actualizarse YA MISMO (por si moviste la cámara rápido)
	interaction_ray.force_raycast_update()
	
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		print("Colisioné con: ", collider.name) # ¿Dice StaticBody3D?
		
		var punto_golpe = interaction_ray.get_collision_point()
		var objeto_padre = collider.get_parent()
		print(objeto_padre)
		if objeto_padre.has_method("cavar"):
			objeto_padre.cavar(punto_golpe, 1.5, 0.4)
			print("¡CAVANDO!")
		else:
			print("El objeto ", objeto_padre.name, " no tiene el script con la función 'cavar'")
	else:
		print("El RayCast no toca nada. Posibles causas:")
		print("1. El rayo es muy corto (Target Position Z).")
		print("2. El StaticBody no tiene CollisionShape.")
