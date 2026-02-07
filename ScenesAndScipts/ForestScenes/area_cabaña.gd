extends Node3D


var activate:bool=false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name=="CharacterBody3D":
		if body.has_method("fin_audio") and !activate:
			body.fin_audio()
			activate=true
			Dialogic.start("1_0")
