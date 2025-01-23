shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;


void fragment() {
	float threshold = 0.3;
	
	if (texture(SCREEN_TEXTURE,SCREEN_UV).r > threshold){
		float red = texture(SCREEN_TEXTURE,SCREEN_UV).r;
		red -= threshold;
		red *= 0.4;
		red += threshold;
		COLOR = vec4(red,0,0,1);
	}
	else {
		COLOR = vec4(0.1,0.1,0.15,1);
		
		float hipixel = texture(SCREEN_TEXTURE,vec2(
		SCREEN_UV.x, SCREEN_UV.y - SCREEN_PIXEL_SIZE.y * 12.0
		)).r;
		if (hipixel > threshold){
			COLOR = vec4(0.05,0.05,0.15,1);
		}
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
