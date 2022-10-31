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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float ageNoise : TEXCOORD0;
            };

            float4 _Color;

            StructuredBuffer<GrassBlade> GrassBladesBuffer;
            float3 WindDirection;
            float WindForce;
            half4 YoungGrassColor;
            half4 OldGrassColor;

            float4 positionVertexInWorld(GrassBlade grassBlade, Attributes IN) {
                // generate a translation matrix to move the vertex
                float4x4 translationMatrix = getTranslation_Matrix(grassBlade.position);
                float4x4 rotationMatrix = getRotationY_Matrix(grassBlade.rotationY);
                float4x4 transformationMatrix = mul(translationMatrix, rotationMatrix);

                // translate the object pos to world pos
                float4 worldPosition = mul(unity_ObjectToWorld, IN.positionOS);
                // then use the matrix to translate and rotate it
                worldPosition = mul(transformationMatrix, worldPosition);

                return worldPosition;
            }

            float4 applyWind(GrassBlade grassBlade, Attributes IN, float4 worldPosition) {
                float3 displaced = worldPosition.xyz + (normalize(WindDirection) * WindForce * grassBlade.windNoise);
                float4 displacedByWind = float4(displaced, 1);

                // base of the grass needs to be static on the floor
                return lerp(worldPosition, displacedByWind, IN.uv.y);
            }

            Varyings vert (Attributes IN, uint vertex_id: SV_VERTEXID, uint instance_id: SV_INSTANCEID)
            {
                Varyings OUT;

                // get the instanced grass blade
                GrassBlade grassBlade = GrassBladesBuffer[instance_id];

                float4 worldPosition = positionVertexInWorld(grassBlade, IN);
                worldPosition = applyWind(grassBlade, IN, worldPosition);

                // translate the world pos to clip pos
                OUT.positionHCS = UnityWorldToClipPos(worldPosition);

                OUT.ageNoise = grassBlade.ageNoise;

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return lerp(YoungGrassColor, OldGrassColor, IN.ageNoise);
            }
            ENDCG
        }
        // shadow caster rendering pass, implemented manually
        // using macros from UnityCG.cginc
        // https://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html
        // Pass
        // {
        //     Tags {"LightMode"="ShadowCaster"}

        //     CGPROGRAM

        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma multi_compile_shadowcaster

        //     #include "UnityCG.cginc"

        //     struct v2f {
        //         float4 uv: TEXCOORD0;
        //         V2F_SHADOW_CASTER;
        //     };

        //     v2f vert(appdata_base v)
        //     {
        //         v2f OUT;
        //         OUT.uv = v.texcoord;
        //         TRANSFER_SHADOW_CASTER_NORMALOFFSET(OUT)
        //         return OUT;
        //     }

        //     float4 frag(v2f IN) : SV_Target
        //     {
        //         SHADOW_CASTER_FRAGMENT(i)
        //     }

        //     ENDCG
        // }
    }
}
