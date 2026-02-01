shader_type spatial;

// --- TEXTURAS ---
// Arrastra aquí la imagen de pasto que encontraste
uniform sampler2D textura_pasto : source_color, filter_linear_mipmap_anisotropic;
// Si tu textura venía con un mapa de normales (azul/violeta), ponlo aquí. Si no, déjalo vacío.
uniform sampler2D normal_pasto : hint_normal, filter_linear_mipmap_anisotropic;

// --- COLORES TIERRA (Mantenemos la tierra como color sólido por ahora) ---
uniform vec3 color_tierra : source_color = vec3(0.3, 0.2, 0.1);
uniform vec3 color_profundo : source_color = vec3(0.15, 0.1, 0.05);

// --- CONFIGURACIÓN ---
uniform vec2 escala_textura = vec2(4.0, 4.0); // Controla qué tan grande se ve la imagen del pasto
uniform float nivel_suelo = -0.1;
uniform float borde_suave = 0.5;

varying float altura_vertice;
varying vec2 uv_detallada;

void vertex() {
	altura_vertice = VERTEX.y;
	// Escalamos las UVs para que la textura se repita y no se vea gigante
	uv_detallada = UV * escala_textura;
}

void fragment() {
	// 1. EXTRAER COLOR DE TU IMAGEN
	vec3 color_imagen_pasto = texture(textura_pasto, uv_detallada).rgb;
	
	// 2. LÓGICA DE ALTURA
	// Calculamos cuánto es tierra y cuánto es pasto según la altura Y
	float factor_mezcla = smoothstep(nivel_suelo - borde_suave, nivel_suelo, altura_vertice);
	
	// 3. MEZCLAR TIERRA CON LA TEXTURA
	// Si factor es 0 = Tierra Marrón. Si es 1 = Tu Textura de Pasto.
	vec3 mezcla_final = mix(color_tierra, color_imagen_pasto, factor_mezcla);
	
	// 4. OSCURECIMIENTO EN PROFUNDIDAD (Tu lógica original)
	if (altura_vertice < (nivel_suelo - 2.0)) {
		mezcla_final = mix(color_profundo, mezcla_final, 0.5);
	}
	
	ALBEDO = mezcla_final;
	
	// 5. NORMAL MAP (Relieve)
	// Solo aplicamos el relieve de la textura donde hay pasto
	vec3 normal_tex = texture(normal_pasto, uv_detallada).rgb;
	// Si no asignas textura normal, por defecto usa azul plano (0.5, 0.5, 1.0) para evitar errores
	vec3 normal_base = vec3(0.5, 0.5, 1.0);
	
	NORMAL_MAP = mix(normal_base, normal_tex, factor_mezcla);
	
	// Ajustes de material
	ROUGHNESS = mix(0.9, 0.8, factor_mezcla); 
	SPECULAR = 0.05;
}