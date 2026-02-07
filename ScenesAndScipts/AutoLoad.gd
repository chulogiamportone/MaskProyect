extends Node
var inicio: Control 
var character_body_3d: CharacterBody3D 


func fin_cinematica_0_0()->void:

	inicio.visible=false
	character_body_3d.start_wake_up()
	
func fin_burn()->void:
	var object_mascara=character_body_3d.OBJECTS.instantiate()
	character_body_3d.sub_viewport_container.add_child(object_mascara)
	character_body_3d.sub_viewport_container.get_child(0).active_object("Mascara")
