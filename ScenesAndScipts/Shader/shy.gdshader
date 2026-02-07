shader_type sky;

uniform vec3 top_color : source_color = vec3(0.0, 0.0, 0.0); // Negro vacío
uniform vec3 cloud_color : source_color = vec3(0.1, 0.0, 0.15); // Nubes violetas oscuras
uniform vec3 lightning_color : source_color = vec3(0.8, 0.6, 1.0); // Luz de rayo
uniform float vortex_size : hint_range(0.5, 0.99) = 0.99;
uniform sampler2D cloud_texture; // Aquí pondrás el ruido
uniform float vortex_speed: hint_range(0.0, 1) = 0.5;
uniform float lightning_strength : hint_range(0.0, 1.0) = 0.1;
uniform float cloud_coverage : hint_range(0.0, 10.0) = 0.8; // 0.0 = Despejado, 1.0 = Todo nublado
uniform vec3 horizon_color : source_color = vec3(0.0, 0.0, 0.05); // NUEVO: Color para disimular el corte
// --- CAMUFLAJE HORIZONTE ---
uniform float horizon_blur : hint_range(0.0, 1.0) = 0.15; // Qué tanto se difumina abajo

vec2 rotate_uv(vec2 uv, float rotation) {
	float mid = 0.5;
	return vec2(
		cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
		cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
	);
}

void sky() {
	vec2 uv = vec2(atan(EYEDIR.x, EYEDIR.z) / (2.0 * 3.1416) + 0.5, EYEDIR.y * 0.5 + 0.5);

	// 1. Vórtice y Nubes
	float twist = (1.0 - uv.y) * 10.0;
	float time_rotation = TIME * vortex_speed;

	vec2 vortex_uv1 = rotate_uv(uv, time_rotation + twist);
	vec2 vortex_uv2 = rotate_uv(uv, (time_rotation * 0.8) - twist);

	float noise1 = texture(cloud_texture, vortex_uv1).r;
	float noise2 = texture(cloud_texture, vortex_uv2).r;

	float noise_value = noise1 * noise2;
	float threshold = 1.0 - cloud_coverage;
	float clouds = smoothstep(threshold, threshold + 0.2, noise_value);

	// 2. Color Base
	vec3 final_sky = mix(top_color, cloud_color, clouds);

	// 3. Ojo del Vórtice
	float center_glow = smoothstep(vortex_size, 1.0, EYEDIR.y);
	final_sky += vec3(0.4, 0.0, 0.8) * center_glow * 2.0;

	// 4. Rayos
	final_sky = mix(final_sky, lightning_color, lightning_strength * clouds);

	// --- NUEVO: Mezcla con el Horizonte ---
	// Calculamos qué tan cerca estamos del horizonte (EYEDIR.y = 0)
	float horizon_factor = abs(EYEDIR.y);
	// Creamos una máscara suave
	float horizon_mask = smoothstep(0.0, horizon_blur, horizon_factor);
	// Mezclamos: Si está cerca del horizonte, usa horizon_color. Si está arriba, usa final_sky.
	final_sky = mix(horizon_color, final_sky, horizon_mask);

	COLOR = final_sky;
}