struct v2f
{
    // Cg Semantics
    //      Binds Shader input/output to rendering hardware
    //      - SV_POSITION means system value position in DX10, corresponds to vertex position
    //      - TEXCOORDn means custom data

    float4 vertex: SV_POSITION; // From Object-Space to Clip-Space
    float4 position: TEXCOORD1;
    float4 uv: TEXCOORD0;
};

v2f vert (appdata_base v)
{
    v2f output;

    output.vertex = UnityObjectToClipPos(v.vertex);
    output.position = v.vertex;
    output.uv = v.texcoord;

    return output;
}
