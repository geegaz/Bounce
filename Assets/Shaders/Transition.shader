shader_type canvas_item;
render_mode unshaded;

uniform vec4 base_color : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 transition_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float transition_state : hint_range(-1.0, 1.0);
uniform float transition_multiplier = 1.0;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	float trs = transition_state*transition_multiplier;
	
	if(UV.x < transition_state || UV.x > 1.0+transition_state) {
		discard;
	}
	else if(UV.x < trs || UV.x > 1.0+trs) {
		COLOR = vec4(transition_color.rgb, alpha);
	}
	else {
		COLOR = vec4(base_color.rgb, alpha);
	}
}