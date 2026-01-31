extends StaticBody3D

var enter_on_area_1:bool=false
var enter_on_area_2:bool=false
var enter_on_area_3:bool=false
var enter_on_area_4:bool=false

@onready var fire: Node3D = $FireContainer/Fire
@onready var fire_2: Node3D = $FireContainer/Fire2
@onready var fire_3: Node3D = $FireContainer/Fire3
@onready var fire_4: Node3D = $FireContainer/Fire4
@onready var fire_5: Node3D = $FireContainer/Fire5
@onready var fire_6: Node3D = $FireContainer/Fire6
@onready var fire_7: Node3D = $FireContainer/Fire7
@onready var fire_8: Node3D = $FireContainer/Fire8
@onready var fire_9: Node3D = $FireContainer/Fire9
@onready var fire_10: Node3D = $FireContainer/Fire10

@onready var fire_container: Node3D = $FireContainer
@onready var fire_mask: Node3D = $FireMask


func _on_area_1_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_1=true

func _on_area_1_body_exited(body: Node3D) -> void:
	enter_on_area_1=false


func _on_area_2_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_2=true
func _on_area_2_body_exited(body: Node3D) -> void:
	enter_on_area_2=false


func _on_area_3_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_3=true

func _on_area_3_body_exited(body: Node3D) -> void:
	enter_on_area_3=false

func _on_area_4_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_4=true


func _on_area_4_body_exited(body: Node3D) -> void:
	enter_on_area_4=false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if enter_on_area_1:
			if !fire.visible:
				fire.visible=true
			elif !fire_2.visible:
				fire_2.visible=true
			elif !fire_3.visible:
				fire_3.visible=true
			
		if enter_on_area_2:
			if !fire_9.visible:
				fire_9.visible=true
			elif !fire_10.visible:
				fire_10.visible=true
		if enter_on_area_3:
			if !fire_6.visible:
				fire_6.visible=true
			elif !fire_7.visible:
				fire_7.visible=true
			elif !fire_8.visible:
				fire_8.visible=true
		if enter_on_area_4:
			if !fire_4.visible:
				fire_4.visible=true
			elif !fire_5.visible:
				fire_5.visible=true
		var verificacion:bool=true
		for fire in fire_container.get_children():
			if !fire.visible:
				verificacion=false
			
		if verificacion:
			fire_mask.visible=true
			
			
			
			
			
