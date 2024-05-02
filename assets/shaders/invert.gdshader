shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = vec4(1.0) - texture(SCREEN_TEXTURE, SCREEN_UV);
	color.a = 1.0;
	COLOR = color * texture(TEXTURE, UV);
}
