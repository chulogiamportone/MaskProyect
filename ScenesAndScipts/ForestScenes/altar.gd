extends StaticBody3D

var enter_on_area_1:bool=false
var enter_on_area_2:bool=false
var enter_on_area_3:bool=false
var enter_on_area_4:bool=false

var enter_on_area_mask:bool=false

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

var is_mask_in_place:bool=false

var body_active:CharacterBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
var finish:bool=false
@onready var timer_2: Timer = $Timer2



func _on_area_1_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_1=true
		body_active=body

func _on_area_1_body_exited(_body: Node3D) -> void:
	enter_on_area_1=false



func _on_area_2_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_2=true
		body_active=body
		
func _on_area_2_body_exited(_body: Node3D) -> void:
	enter_on_area_2=false



func _on_area_3_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_3=true
		body_active=body

func _on_area_3_body_exited(_body: Node3D) -> void:
	enter_on_area_3=false


func _on_area_4_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_4=true
		body_active=body


func _on_area_4_body_exited(_body: Node3D) -> void:
	enter_on_area_4=false


func _process(_delta: float) -> void:
	if !finish:
		if Input.is_action_just_pressed("click") and is_mask_in_place and body_active.tiene_craneo :
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
			for fire_count in fire_container.get_children():
				if !fire.visible:
					verificacion=false
				
			if verificacion:
				fire_mask.visible=true
				body_active.fire_audio.play()
				timer.start()
				
				
		if Input.is_action_just_pressed("click") and enter_on_area_mask and !is_mask_in_place and body_active:
			body_active.block=true
			is_mask_in_place=true
			animation_player.play("mask_place")
		
			
			
			
			


func _on_area_mask_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		enter_on_area_mask=true
		body_active=body


func _on_area_mask_body_exited(_body: Node3D) -> void:
	enter_on_area_mask=false


func _on_timer_timeout() -> void:
	timer.stop()
	fire_mask.visible=false
	body_active.fire_audio.fade_out_y_apagar()
	finish=true
	animation_player.play_backwards("mask_place")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if finish:
		body_active.block=false
		body_active.is_mask_active=true
		body_active.animation_player.play("mask_move")
		body_active.quema.play()
		body_active.quema.fade_out_y_apagar()
		body_active.quema_2.play()
		body_active.tiene_mascara=true
		
		
		#Texto4
		body_active.label_mision.text="Follow the blood, ear your intuition."
		body_active.music_section_2.play()
		timer_2.start()

func _on_timer_2_timeout() -> void:
	if body_active:
		body_active.music_section_2.fade_out_y_apagar()
		body_active.tiene_mascara=true
		body_active=null
