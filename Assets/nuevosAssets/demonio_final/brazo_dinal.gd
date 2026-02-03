extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		animation_player.play("final")
		#Texto8 y final
		body.label_mision.text="If you are looking for the darkness, look inside you. There is it."
