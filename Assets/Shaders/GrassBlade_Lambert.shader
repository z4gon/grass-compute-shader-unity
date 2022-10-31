Shader "Unlit/GrassBlade_Lambert"
{
    Properties
    {
        _Color ("Color", Color) = (0,1,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #include "./shared/GrassBlade.cginc"
            #include "./shared/Transformations.cginc"

            struct Input
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            StructuredBuffer<GrassBlade> GrassBladesBuffer;

            Varyings vert (Input IN, uint vertex_id: SV_VERTEXID, uint instance_id: SV_INSTANCEID)
            {
                Varyings OUT;

                // get the instanced grass blade
                GrassBlade grassBlade = GrassBladesBuffer[instance_id];

                // generate a translation matrix to move the vertex
                float4x4 translationMatrix = getTranslation_Matrix(grassBlade.position);

                // translate the object pos to world pos, then use the matrix to translate it
                float4 worldPosition = mul(unity_ObjectToWorld, IN.positionOS);
                worldPosition = mul(translationMatrix, worldPosition);

                // translate the world pos to clip pos
                OUT.positionHCS = UnityWorldToClipPos(worldPosition);

                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
