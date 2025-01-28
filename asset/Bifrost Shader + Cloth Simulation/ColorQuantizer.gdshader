shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
uniform float opacity = 0.6;
uniform float tint_brightness = 1.3;
uniform float base_brightness = 0.9;
uniform sampler2D specular_map : repeat_enable;
uniform vec4 specular_color = vec4(0.4,0.7,0.9,1.2);
uniform float specular_contrast = 5.0;
uniform float specular_spread = 1.0;

void fragment() {
	
	
	// Le nombre de couleurs dans la palette
	const int number_of_colors = 5;
	//
	
	vec4 Colors[number_of_colors];
	
	// La palette de couleur en format RGBA sur la plage 0-255. Alpha devrait toujours valoir 255 sauf dans des cas exceptionnels.
	// Exemple : Colors[x] = vec4(ROUGE,VERT,BLEU,ALPHA)/255.0. 
	// Un x plus élevé signifie uuleur plus claire. 
	// Les index des couleurs doivent aller de 0 à number_of_colors - 1 et il doit y avoir autant de couleur que précisé au dessus.
	Colors[4] = vec4(255,255,255,255)/255.0 ;
	Colors[3] = vec4(0,234,247,255)/255.0 ;
	Colors[2] = vec4(0,183,219,255)/255.0 ;
	Colors[1] = vec4(0,69,153,255)/255.0 ;
	Colors[0] = vec4(0,10,69,0)/255.0 ;
	//
	
	
	
	
	
	
	
	
	
	//
	//Colors[0] = vec4(59,127,217,255)/255.0 ;
	//Colors[1] = vec4(82,161,217,255)/255.0 ;
	//Colors[2] = vec4(63,206,217,255)/255.0 ;
	//Colors[3] = vec4(137,214,218,255)/255.0 ;
	//Colors[4] = vec4(255,255,255,255)/255.0 ;
	//
	//Colors[4] = vec4(0,187,255,255)/255.0 ;
	//Colors[3] = vec4(255,0,195,255)/255.0 ;
	//Colors[2] = vec4(136,0,255,255)/255.0 ;
	//Colors[1] = vec4(30,0,255,255)/255.0 ;
	//Colors[0] = vec4(0,2,105,0)/255.0 ;

	//Colors[4] = vec4(255,255,255,255)/255.0 ;
	//Colors[3] = vec4(0,234,247,255)/255.0 ;
	//Colors[2] = vec4(0,183,219,255)/255.0 ;
	//Colors[1] = vec4(0,69,153,255)/255.0 ;
	//Colors[0] = vec4(0,10,69,0)/255.0 ;
	
	//--------------------------------------------------------------------------------------------------------------------------
	
	vec4 CurrentPixel = texture(TEXTURE,UV);
	float CurrentShade = CurrentPixel.r + CurrentPixel.g + CurrentPixel.b;
	CurrentShade /= 3.0;
	
	int ColorNum = Colors.length();
	float ColorSlice = 1.0/(float(ColorNum));
	for (int i = 0; i <= ColorNum; i++){
		if (CurrentShade >= ColorSlice*float(ColorNum-i-1)){
			CurrentPixel.rgb = Colors[ColorNum-i-1].rgb;
			break;
		}
	}
	COLOR.rgb = CurrentPixel.rgb * opacity * tint_brightness;
	COLOR.rgb += texture(TEXTURE,UV).rgb * (1.0-opacity) * base_brightness;
	COLOR.rgb += (pow(texture(specular_map,SCREEN_UV).r,specular_contrast)*specular_color.rgb*specular_color.a)
	*(1.0 - CurrentShade / specular_spread);
	COLOR.a = texture(TEXTURE,UV).a;
}