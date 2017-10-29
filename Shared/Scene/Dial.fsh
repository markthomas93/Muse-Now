void main(void){
    
    vec4 dial = texture2D(u_texture, v_tex_coord);  // watch dial w hour color index
    vec4 mask = texture2D(u_mask, v_tex_coord);     // watch dial w mono clipping mask
    float ndx = (dial.x * 255.0 + 0.5) / u_count; // index into color palette
    vec4 pal = texture2D(u_pal, vec2(ndx,abs(u_fade))); // color palette
    vec4 anim = texture2D(u_anim, vec2(ndx,u_frame)); // animation fade val

    gl_FragColor = vec4(pal.x * mask.x * anim.x,
                        pal.y * mask.y * anim.x,
                        pal.z * mask.z * anim.x,
                        1.0);
}
