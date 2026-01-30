shader_type canvas_item;

// Referencia a lo que ve la cámara
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// La "paleta de calor" (de azul a rojo/blanco)
uniform sampler2D gradient_texture : source_color;

// Configuraciones del efecto
uniform float noise_amount : hint_range(0.0, 1.0) = 0.05;
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.2;
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.1; // Ignorar cosas muy oscuras (frías)

// Función para generar ruido aleatorio (grano)
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	// 1. Obtener el color original de la pantalla
	vec4 original_color = texture(screen_texture, SCREEN_UV);
	
	// 2. Calcular la "Luminancia" (qué tan brillante es el píxel).
	// Usamos esto para simular temperatura: Más brillo = Más calor.
	float brightness = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
	
	// Aplicar un pequeño umbral para que lo negro sea azul oscuro (frío)
	brightness = max(brightness, brightness_threshold);

	// 3. Mapear el brillo a nuestra textura degradada (Heat Map)
	vec4 thermal_color = texture(gradient_texture, vec2(brightness, 0.0));
	
	// 4. Agregar Ruido (Efecto de sensor sucio/realista)
	float noise = random(UV + vec2(TIME * 10.0, 0.0)) * noise_amount;
	thermal_color.rgb += noise;

	// 5. Agregar Viñeta (Bordes oscuros del visor)
	vec2 center_dist = UV - vec2(0.5);
	float dist_val = 1.0 - dot(center_dist, center_dist) * vignette_strength;
	thermal_color.rgb *= clamp(dist_val, 0.0, 1.0);

	// Asignar el color final
	COLOR = thermal_color;
}