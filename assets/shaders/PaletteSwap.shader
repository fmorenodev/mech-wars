shader_type canvas_item;

//first
uniform vec4 first_color : hint_color;
uniform vec4 first_replacement_color : hint_color;
uniform float first_color_threshold : hint_range(0.0, 1.0, 0.001);

//second
uniform vec4 second_color : hint_color;
uniform vec4 second_replacement_color : hint_color;
uniform float second_color_threshold : hint_range(0.0, 1.0, 0.001);

//third
uniform vec4 third_color : hint_color;
uniform vec4 third_replacement_color : hint_color;
uniform float third_color_threshold : hint_range(0.0, 1.0, 0.001);

//fourth
uniform vec4 fourth_color : hint_color;
uniform vec4 fourth_replacement_color : hint_color;
uniform float fourth_color_threshold : hint_range(0.0, 1.0, 0.001);

//fifth
uniform vec4 fifth_color : hint_color;
uniform vec4 fifth_replacement_color : hint_color;
uniform float fifth_color_threshold : hint_range(0.0, 1.0, 0.001);

//sixth
uniform vec4 sixth_color : hint_color;
uniform vec4 sixth_replacement_color : hint_color;
uniform float sixth_color_threshold : hint_range(0.0, 1.0, 0.001);

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV);
	
	float first_distance = length(tex_color.rgb - first_color.rgb);
	float second_distance = length(tex_color.rgb - second_color.rgb);
	float third_distance = length(tex_color.rgb - third_color.rgb);
	float fourth_distance = length(tex_color.rgb - fourth_color.rgb);
	float fifth_distance = length(tex_color.rgb - fifth_color.rgb);
	float sixth_distance = length(tex_color.rgb - sixth_color.rgb);
	
	if (COLOR.a != 0.0) {
		if(first_distance < first_color_threshold){
			tex_color = first_replacement_color;
		}else if(second_distance < second_color_threshold){
			tex_color = second_replacement_color;
		}else if(third_distance < third_color_threshold){
			tex_color = third_replacement_color;
		}else if(fourth_distance < fourth_color_threshold){
			tex_color = fourth_replacement_color;
		}else if(fifth_distance < fifth_color_threshold){
			tex_color = fifth_replacement_color;
		}else if(sixth_distance < sixth_color_threshold){
			tex_color = sixth_replacement_color;
		}
	}
	
	COLOR = tex_color;
}