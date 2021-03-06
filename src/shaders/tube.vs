#version 330

#include uniforms_vs
#include textures_vs
#include peel_vs

in float a_direction;

uniform float u_thickness;

out float v_sparam;
out float v_tangent_dot_view;
out float v_location;

out float v_discard;

void main()
{
    v_position = mvp_matrix * userTransformMatrix * vec4( a_position, 1.0 );
    
    v_normal = normalize( a_normal );
    v_index = a_indexes;

    vec3 tangent = normalize( ( mv_matrixTI * vec4( v_normal, 1.0 ) ).xyz );
        
    vec3 view = vec3( 0.0, 0.0, -1.0 );
    
    vec3 offsetNN = cross( tangent, view );
    v_tangent_dot_view = length( offsetNN ); 
    
    vec3 offset = normalize( offsetNN );
    offset.x *= u_thickness;
    offset.y *= u_thickness;
    
    v_sparam = a_direction;
    v_position.xyz =  ( offset * v_sparam ) + v_position.xyz;

    gl_Position = v_position; //< store final position
	
	v_extra = a_extra;
   
	if ( u_colorMode == 0 )
	{
	   frontColor = u_globalColor;
	}
	else if ( u_colorMode == 1 )
	{
	   frontColor = vec4( abs( v_normal ), 1.0 );
	}
	else
    {
       frontColor =  vec4( u_color.xyz, 1.0 );
    }
    
    v_discard = 0.0;
    if ( a_position.x <= ( u_x - u_dx ) || a_position.x >= ( u_x + u_dx ) || 
         a_position.y <= ( u_y - u_dy ) || a_position.y >= ( u_y + u_dy ) ||
         a_position.z <= ( u_z - u_dz ) || a_position.z >= ( u_z + u_dz ) )
    {
        v_discard = 1.0;
    } 
    
    calcTexCoords();
}
