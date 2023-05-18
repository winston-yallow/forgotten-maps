shader_type canvas_item;

const float SMOOTHNESS = 0.15;
const float SMOOTHNESS_FACTOR = 1.0 + SMOOTHNESS;
const float SMOOTHNESS_HALF = SMOOTHNESS / 2.0;

uniform sampler2D mask_texture : source_color, hint_default_white;
uniform sampler2D noise_texture : source_color, hint_default_white;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	float mask = texture(mask_texture, UV).x;
	float noise = texture(noise_texture, SCREEN_UV).x;
	float alpha = smoothstep(
		noise - SMOOTHNESS_HALF,
		noise + SMOOTHNESS_HALF,
		(mask * SMOOTHNESS_FACTOR) - SMOOTHNESS_HALF
	);
	COLOR.a *= alpha;
}
