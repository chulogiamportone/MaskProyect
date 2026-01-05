shader_type spatial;

// Render mode: specular_schlick_ggx da brillos más realistas en vidrio
render_mode specular_schlick_ggx;

uniform sampler2D viewport_texture : source_color; // Tu cámara espejo
uniform sampler2D glass_normal; // Ruido suave para simular el pandeo del vidrio grande
uniform vec4 glass_tint : source_color = vec4(0.85, 0.95, 0.92, 1.0); // Tinte verde agua suave
uniform float reflection_mix : hint_range(0.0, 1.0) = 0.9; // Qué tanto se ve el reflejo vs el vidrio
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02; // Distorsión muy leve

void fragment() {
    // 1. Coordenadas de pantalla para mapear el reflejo (Screen mapping)
    // Usamos SCREEN_UV para que parezca más un reflejo real que una textura pegada, 
    // pero como usas SubViewport, mantendremos UV estándar con distorsión.
    
    // 2. Distorsión suave (Warping)
    // Simula que el vidrio es una plancha grande y no es perfectamente plana.
    vec3 normal_map = texture(glass_normal, UV).rgb;
    vec2 distorted_uv = UV + ((normal_map.rg - 0.5) * distortion_strength);

    // 3. Obtener imagen de la cámara
    vec4 reflection = texture(viewport_texture, distorted_uv);

    // 4. Aplicar el tinte de "Vidrio Templado"
    // Las vidrieras no reflejan el color puro, lo "enfrían" un poco.
    vec3 final_color = mix(glass_tint.rgb, reflection.rgb, reflection_mix);

    // 5. Asignar al Albedo
    ALBEDO = final_color;

    // 6. Propiedades físicas para que la luz del sol "pegue" en el vidrio
    METALLIC = 0.9;  // Muy alto, casi espejo
    ROUGHNESS = 0.02; // Casi cero, muy pulido (vidrio nuevo)
    SPECULAR = 1.0;   // Brillo máximo
    
    // Opcional: Si tienes un mapa de normales suave, úsalo aquí
    NORMAL_MAP = normal_map;
    NORMAL_MAP_DEPTH = 0.5;
}