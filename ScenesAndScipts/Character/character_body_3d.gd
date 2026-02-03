extends CharacterBody3D

# --- CONFIGURACIÓN ---
@export var WALKING_SPEED = 5.0
@export var RUNNING_SPEED = 9.0
@export var CROUCH_SPEED = 3.0
@export var JUMP_VELOCITY = 6
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
var tiene_pala : bool = false
@onready var visual_pala_mano = $schaufel# Ajusta la ruta si es distinta
@export var scene_pala : PackedScene=preload("uid://jm45o6r0m1ly")

var tiene_craneo : bool = false
var tiene_mascara : bool = false
var tiene_brazo : bool = false

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $MusicSection1
@onready var cavar: AudioStreamPlayer3D = $Cavar
@onready var fire_audio: AudioStreamPlayer3D = $Fire
@onready var quema: AudioStreamPlayer3D = $Quema
@onready var quema_2: AudioStreamPlayer3D = $Quema2
@onready var music_section_2: AudioStreamPlayer3D = $MusicSection2
@onready var final: AudioStreamPlayer3D = $final


@export var SEVERED_ARM : PackedScene

var block:bool=false

@onready var sub_viewport_container: SubViewportContainer = $"../Object/SubViewportContainer"
const OBJECTS = preload("uid://bb6abjwj6in2j")

@onready var label_mision: Label = $"../Mision/Label"




func _ready():
	visual_pala_mano.visible=false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mask_visible=get_tree().get_nodes_in_group("mask_visible")
	interaction_ray.add_exception(self)
	Dialogic.start("0_0")

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
	
	if Input.is_action_just_pressed("action") and !is_mask_active and !block:
		is_mask_active=true
		mask_canvas_layer.visible=true
		animation_player.play("mask_move")
		
	else:
		if Input.is_action_just_pressed("action") and is_mask_active and !block:
			mask_canvas_layer.visible=false
			is_mask_active=false
			
			for object in mask_visible:
				object.visible=false
			animation_player.play_backwards("mask_move")
	if block:
		is_mask_active=false
	
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

var block_animation:bool=false
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if is_mask_active and !block_animation:
		block_animation=true
		mask_canvas_layer.visible=true
		block=false
		for object in mask_visible:
			object.visible=true
		
		var object_mascara=await OBJECTS.instantiate()
		sub_viewport_container.add_child(object_mascara)
		object_mascara.active_object("Mascara")
		


func intentar_cavar():
	interaction_ray.force_raycast_update()
	
	if interaction_ray.is_colliding():
		
		var objeto = interaction_ray.get_collider()
		
		# CASO 1: Es un objeto agarrable (La pala del suelo)
		if objeto.has_method("interactuar"):
			objeto.interactuar(self)
			return # Ya hicimos algo, no seguimos
			
		# CASO 2: Es el suelo y queremos cavar
		# Buscamos si el objeto o sus padres tienen la función cavar
		var objeto_cavar = objeto
		if not objeto_cavar.has_method("cavar") and objeto.get_parent().has_method("cavar"):
			objeto_cavar = objeto.get_parent()
			
		if objeto_cavar.has_method("cavar"):
			if tiene_pala:
				# SALTO DE SEGURIDAD (El truco que ya tenías)
				global_position.y += 0.2
				velocity.y = 0
				cavar.reproducir_segmento()
				objeto_cavar.cavar(interaction_ray.get_collision_point(), 1.5, 0.5)
			else:
				print("Necesito una pala para hacer eso.")
				
func equipar_pala():
	if !tiene_craneo:
		tiene_pala = true
		visual_pala_mano.visible = true # ¡Ahora la ves en tu mano!
		print("¡Has conseguido la pala!")
		Dialogic.start("0_1")
	
func soltar_pala():
	# 1. Lógica interna
	tiene_pala = false
	visual_pala_mano.visible = false
	print("Pala soltada")
	
	# 2. Instanciar el objeto físico en el mundo
	if scene_pala:
		var pala_fisica = scene_pala.instantiate()
		
		# La añadimos a la escena principal (no al player, para que no se mueva con nosotros)
		get_parent().add_child(pala_fisica)
		
		# 3. Posicionarla frente a nosotros
		# Usamos la posición de la cámara (head) y la adelantamos 1.5 metros
		pala_fisica.global_position = head.global_position - head.global_transform.basis.z * 1.5
		
		# (Opcional) Tirarla con un poco de fuerza hacia adelante
		pala_fisica.linear_velocity = -head.global_transform.basis.z * 5.0 # Impulso de 5 metros/seg
		pala_fisica.angular_velocity = Vector3(randf(), randf(), randf()) * 5 # Un giro random para que se vea cool
	else:
		printerr("ERROR: No has asignado la escena 'scene_pala' en el Inspector del Player")
		
func soltar_brazo():

	# 2. Instanciar el objeto físico en el mundo
	if SEVERED_ARM:
		var pala_fisica = SEVERED_ARM.instantiate()
		
		# La añadimos a la escena principal (no al player, para que no se mueva con nosotros)
		get_parent().add_child(pala_fisica)
		
		# 3. Posicionarla frente a nosotros
		# Usamos la posición de la cámara (head) y la adelantamos 1.5 metros
		pala_fisica.global_position = head.global_position - head.global_transform.basis.z * 1.5
		
		# (Opcional) Tirarla con un poco de fuerza hacia adelante
		
	else:
		printerr("ERROR: No has asignado la escena 'SEVERED_ARM' en el Inspector del Player")


func equipar_craneo():
	tiene_craneo = true
	var object_craneo=OBJECTS.instantiate()
	sub_viewport_container.add_child(object_craneo)
	object_craneo.active_object("Craneo")
	print("¡Has conseguido el craneo!")
	audio_stream_player_3d.play()
	#Texto2, el primero en cambiar por codigo
	label_mision.text="Follow the blood, ear your intuition."
	
	
func fin_audio():
	audio_stream_player_3d.fade_out_y_apagar(2.0)

func equipar_brazo():
	tiene_brazo = true
	print("¡Has conseguido el brazo!")
	var object_brazo= OBJECTS.instantiate()
	sub_viewport_container.add_child(object_brazo)
	object_brazo.active_object("Brazo")
	#Texto6
	label_mision.text="Place the sacrifices next to the ceremonial skull."


func _on_music_section_2_finished() -> void:
	#Texto5
	label_mision.text="Sacrifice your arm,give them some blood."


func start_wake_up()->void:
	animation_player.play("inicio")
