shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

// --- 1. ALEATORIEDAD GLOBAL (Para romper patrones entre objetos) ---
group_uniforms Aleatoriedad_Instancia;
instance uniform float semilla_instancia : hint_range(0.0, 100.0, 0.1) = 0.0;
uniform float fuerza_desincronizacion : hint_range(0.0, 10.0) = 2.0;

// --- 2. ESTRUCTURA DEL CAMINO ---
group_uniforms Estructura;
uniform float densidad_vertical : hint_range(1.0, 20.0) = 4.0; 
uniform float repeticion_horizontal : hint_range(1.0, 10.0) = 1.0; 
uniform float separacion_pies : hint_range(0.0, 0.5) = 0.15; 

// --- 3. SECUENCIA DE APARICIÓN (El Fantasma Caminando) ---
group_uniforms Secuencia_Caminata;
uniform float velocidad_secuencia : hint_range(0.0, 10.0) = 3.0;
uniform float direccion_secuencia : hint_range(-1.0, 1.0, 2.0) = 1.0;
// ESTA ES LA VARIABLE QUE PEDISTE:
// 0.0 = Mitad prendido / Mitad apagado.
// 0.8 = Mucho tiempo apagado / Breve encendido.
uniform float recorte_tiempo_prendido : hint_range(-1.0, 0.95) = 0.5;
uniform float dureza_aparicion : hint_range(0.0, 1.0) = 0.5;

// --- 4. PARPADEO STROBO (La Luz Rota - RECUPERADO) ---
group_uniforms Parpadeo_Strobo;
uniform bool activar_strobo = true;
uniform float velocidad_strobo : hint_range(0.0, 50.0) = 10.0; // Velocidad del temblor
uniform float dureza_strobo : hint_range(0.0, 1.0) = 0.8; // 1.0 = Luz cortante
uniform float desincronizacion_strobo : hint_range(0.0, 10.0) = 2.0;
uniform float luz_minima_strobo : hint_range(0.0, 1.0) = 0.1; // Para que no se apague 100% al parpadear

// --- 5. GOTAS Y FORMA ---
group_uniforms Salpicadura;
uniform int gotas_por_paso : hint_range(1, 10) = 3; 
uniform float dispersion : hint_range(0.0, 0.5) = 0.1; 

group_uniforms Variaciones_Tamano;
uniform float tamano_chico : hint_range(0.00, 0.2) = 0.05;
uniform float tamano_medio : hint_range(0.0, 0.3) = 0.15;
uniform float tamano_grande : hint_range(0.0, 0.5) = 0.25;

// --- 6. APARIENCIA ---
group_uniforms Color_y_Ruido;
uniform vec4 color_sangre : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform vec4 color_brillo : source_color = vec4(1.0, 0.2, 0.1, 1.0);
uniform float intensidad_brillo : hint_range(1.0, 20.0) = 8.0;
uniform sampler2D textura_ruido : filter_linear_mipmap, repeat_enable;
uniform float distorsion_liquida : hint_range(0.0, 0.5) = 0.1;
// Luz base cuando la secuencia está "apagada" (normalmente 0 para invisibilidad)
uniform float luz_invisibilidad : hint_range(0.0, 1.0) = 0.0;

// Función Random
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // --- 1. Grilla y Coordenadas ---
    vec2 uv = UV;
    vec2 uv_grid = uv * vec2(repeticion_horizontal, densidad_vertical);
    
    float row_index = floor(uv_grid.y);
    float col_index = floor(uv_grid.x);
    vec2 uv_cell = fract(uv_grid);
    
    // --- 2. Forma de Gotas ---
    float es_impar = mod(row_index, 2.0);
    float lado = (es_impar * 2.0) - 1.0;
    
    float centro_x_base = 0.5 + (separacion_pies * lado);
    vec2 centro_base = vec2(centro_x_base, 0.5);

    float forma_total = 0.0;
    vec2 ruido_uv = uv + vec2(TIME * 0.2); 
    float valor_ruido = texture(textura_ruido, ruido_uv).r;

    for (int i = 0; i < gotas_por_paso; i++) {
        vec2 semilla = vec2(row_index + col_index * 50.0 + semilla_instancia, float(i));
        float rnd_pos = random(semilla);
        float rnd_tam = random(semilla + 1.0);

        float offset_x = (rnd_pos - 0.5) * dispersion;
        float offset_y = (random(semilla + 2.0) - 0.5) * dispersion;
        vec2 centro_gota = centro_base + vec2(offset_x, offset_y);

        float radio_actual = 0.0;
        if (rnd_tam < 0.33) { radio_actual = tamano_chico; }
        else if (rnd_tam < 0.66) { radio_actual = tamano_medio; }
        else { radio_actual = tamano_grande; }
        
        float dist = length(uv_cell - centro_gota);
        dist += (valor_ruido - 0.5) * distorsion_liquida;
        float gota = 1.0 - smoothstep(radio_actual - 0.01, radio_actual, dist);
        
        forma_total = max(forma_total, gota);
    }

    // --- 3. LÓGICA DE SECUENCIA (Caminar) ---
    float desfase_temporal = semilla_instancia * fuerza_desincronizacion;
    float tiempo_efectivo = (TIME * velocidad_secuencia * direccion_secuencia) + desfase_temporal;
    float fase_posicion = row_index + (col_index * 2.0);
    
    // Onda base (-1 a 1)
    float onda_secuencia = sin(tiempo_efectivo - fase_posicion);
    
    // APLICACIÓN DEL RECORTE DE TIEMPO (Más apagado que prendido)
    // Solo dejamos pasar la onda si supera el "recorte".
    // smoothstep maneja la transición suave o dura según 'dureza_aparicion'
    float visibilidad_secuencia = smoothstep(recorte_tiempo_prendido, recorte_tiempo_prendido + (1.0 - dureza_aparicion) * 0.5 + 0.01, onda_secuencia);
    
    // --- 4. LÓGICA DE STROBO (Parpadeo rápido) ---
    float factor_strobo = 1.0;
    if (activar_strobo) {
        float fase_strobo = (row_index + col_index) * desincronizacion_strobo;
        float onda_strobo = sin(TIME * velocidad_strobo + fase_strobo);
        // Convertimos onda (-1 a 1) en factor (0 a 1)
        float base_strobo = 0.5 + 0.5 * onda_strobo;
        // Aplicamos dureza
        float strobo_final = smoothstep(0.5 - (1.0 - dureza_strobo)*0.5, 0.5 + (1.0 - dureza_strobo)*0.5, base_strobo);
        // Mezclamos con luz mínima
        factor_strobo = mix(luz_minima_strobo, 1.0, strobo_final);
    }

    // --- 5. Combinación Final ---
    // La luz final depende de: Secuencia (Caminar) * Strobo (Falla de luz)
    float luz_total_dinamica = visibilidad_secuencia * factor_strobo;
    
    // Si la secuencia dice "apagado", usamos la luz_invisibilidad (normalmente 0)
    // Si la secuencia dice "prendido", usamos el cálculo del strobo
    float factor_luz_final = mix(luz_invisibilidad, factor_strobo, visibilidad_secuencia);

    // Salida
    vec3 color_final = mix(color_sangre.rgb, color_brillo.rgb, valor_ruido);
    
    // El Alpha se corta si la luz es muy baja para ahorrar renderizado visual
    ALBEDO = color_final;
    ALPHA = forma_total * factor_luz_final; 
    EMISSION = color_final * intensidad_brillo * forma_total * factor_luz_final;
}