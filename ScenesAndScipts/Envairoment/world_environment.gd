extends WorldEnvironment

@onready var sky_mat : ShaderMaterial = environment.sky.sky_material

var time_until_lightning = 0.0
var lightning_duration = 0.0
var is_flashing = false

func _process(delta):
	# Temporizador para el próximo rayo
	if time_until_lightning > 0:
		time_until_lightning -= delta
	else:
		trigger_lightning()

	# Lógica del flash
	if is_flashing:
		lightning_duration -= delta
		# Hacemos que la intensidad varíe locamente para parecer un relámpago
		var flash_intensity = randf_range(0.5, 1.0) 
		
		sky_mat.set_shader_parameter("lightning_strength", flash_intensity)
		
		# Apagar rayo
		if lightning_duration <= 0:
			is_flashing = false
			sky_mat.set_shader_parameter("lightning_strength", 0.0)
			# Randomizar próximo rayo entre 3 y 10 segundos
			time_until_lightning = randf_range(3.0, 10.0)

func trigger_lightning():
	is_flashing = true
	# El rayo dura muy poco (entre 0.1 y 0.3 segundos)
	lightning_duration = randf_range(0.1, 0.4)
	
	# Opcional: Aquí podrías reproducir un sonido 
	# $ThunderSound.play()
