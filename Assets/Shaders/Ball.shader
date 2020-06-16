shader_type canvas_item;

uniform float outline_width : hint_range(0.0, 40.0) = 17.0;
uniform vec4 outline_color : hint_color = vec4(0.0, 0.34, 0.47, 1.0);
uniform vec4 base_color : hint_color = vec4(0.0, 0.89, 1.0, 1.0);
uniform bool use_8way_kernel = true;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE * outline_width;
	float a;
	float maxa = col.a;
	float mina = col.a;
	
	float kernel = 2.0;
	if(use_8way_kernel) {
		kernel = 1.0
	}
	
	for(float y = -1.0; y <= 1.0; y += kernel) {
		for(float x = -1.0; x <= 1.0; x += kernel) {
			if(vec2(x,y) == vec2(0.0)) {
				continue;
			}
			
			a = texture(TEXTURE, UV + vec2(x,y)*ps).a;
			maxa = max(a, maxa);
			mina = min(a, mina);
		}
	}
	
	if(col.a == 0.0){
		COLOR = mix(col, outline_color, maxa-mina);
	} else {
		COLOR = vec4(base_color.rgb, col.a);
	}
}