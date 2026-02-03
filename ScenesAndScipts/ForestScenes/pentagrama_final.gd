
extends Node3D


var craneo_enter:bool=false
var brazo_enter:bool=false
var craneo_active:bool=false
var brazo_active:bool=false
var body_active:CharacterBody3D
@onready var craneo: MeshInstance3D = $head
@onready var brazo: Node3D = $BrazoRoto

@export var inactive_portal:MeshInstance3D



func _on_craneo_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		craneo_enter=true
		body_active=body


func _on_craneo_body_exited(_body: Node3D) -> void:
	craneo_enter=false


func _on_brazo_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		brazo_enter=true
		body_active=body


func _on_brazo_body_exited(_body: Node3D) -> void:
	brazo_enter=false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") and craneo_enter  :
		craneo_active=true
		craneo.visible=true
			
	if Input.is_action_just_pressed("click") and brazo_enter  :
		brazo_active=true
		brazo.visible=true
		
	if brazo_active and craneo_active:
		inactive_portal.visible=true
		#Texto7
		body_active.label_mision.text="Your blood its not enought, give them your soul."
		
