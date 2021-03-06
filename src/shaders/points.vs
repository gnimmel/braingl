#version 330

#include uniforms_vs
#include peel_vs

uniform float threshold;
uniform float radius;
uniform float minlength;
uniform float u_scale;
uniform mat4 rot_matrix;
uniform float u_beta;

in vec3 a_to;
in vec3 dg;
in vec3 dc;

out float v_discard;
out float out_value;

void main()
{
    vec3 d = abs( normalize( dc ) );
    frontColor =  vec4(d, pow( a_value, 10*(1-u_beta) ) );
    if ( threshold < a_value && length(a_position-a_to) > minlength) {
        v_discard = 0.0;
    } else {
        v_discard = 1.0;
    }

    vec4 p = vec4( a_position, 0.0) + rot_matrix * vec4((radius*dg), 1.0 );
    
	v_position = mvp_matrix * p;
	
	v_position += vec4(0,0,-0.00001*u_scale,0);
    gl_Position = v_position;  

    out_value = a_value;
}
