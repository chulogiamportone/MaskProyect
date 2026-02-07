extends SubViewport
@onready var head: MeshInstance3D = $Craneo/head
@onready var brazo_roto: Node3D = $Craneo/BrazoRoto
@onready var mascara: Node3D = $Craneo/Mascara
@onready var label_3d_2: Label3D = $Label3D2

var local_type:String
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if local_type=="Craneo":
			Dialogic.start("0_2")
	
		self.queue_free()
		
func _on_button_pressed() -> void:
	if local_type=="Craneo":
		Dialogic.start("0_2")
	
	self.queue_free()

func active_object(type:String)->void:
	local_type=type
	if type=="Craneo":
		head.visible=true
		brazo_roto.visible=false
		mascara.visible=false
		label_3d_2.text="Mom Skull"
	if type=="Brazo":
		head.visible=false
		brazo_roto.visible=true
		mascara.visible=false
		label_3d_2.text="Left Arm"
	if type=="Mascara":
		head.visible=false
		brazo_roto.visible=false
		mascara.visible=true
		label_3d_2.text="Zomok's Mask"
	pass
