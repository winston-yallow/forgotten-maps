shader_type canvas_item;

uniform float offset = 0.5;
uniform sampler2D compass : source_color, hint_default_white, repeat_enable;
uniform sampler2D falloff : source_color, hint_default_white;

void fragment() {
	COLOR = texture(compass, UV + vec2(offset, 0.0));
	COLOR.a *= texture(falloff, abs(UV * 2.0 - 1.0)).x;
}
