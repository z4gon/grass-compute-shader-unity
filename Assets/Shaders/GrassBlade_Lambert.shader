Shader "Unlit/GrassBlade_Lambert"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            // compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase
            // shadow helper functions and macros
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            #include "./shared/GrassBlade.cginc"
            #include "./shared/Transformations.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD;
                float4 normal : NORMAL;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float ageNoise : TEXCOORD0;
                fixed3 diffuse: COLOR0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
            };

            #include "./shared/GrassVertexManipulations.cginc"

            StructuredBuffer<GrassBlade> GrassBladesBuffer;
            float3 WindDirection;
            float WindForce;
            half4 YoungGrassColor;
            half4 OldGrassColor;

            Varyings vert (Attributes IN, uint vertex_id: SV_VERTEXID, uint instance_id: SV_INSTANCEID)
            {
                Varyings OUT;

                // position vertex for GPU instancing ---------------------------------------------------

                GrassBlade grassBlade;
                OUT.pos = positionGrassVertexInHClipPos(
                    GrassBladesBuffer,
                    instance_id,
                    grassBlade,
                    IN.positionOS,
                    IN.uv,
                    WindDirection,
                    WindForce
                );

                // shadows -------------------------------------------------------------------------------

                TRANSFER_SHADOW(OUT)

                // color ---------------------------------------------------------------------------------

                OUT.ageNoise = grassBlade.ageNoise;

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(IN);
                return lerp(YoungGrassColor, OldGrassColor, IN.ageNoise) /* * float4(IN.diffuse, 1) */ * clamp(shadow, 0.3, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile_shadowcaster

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
            };

            #include "./shared/GrassVertexManipulations.cginc"

            StructuredBuffer<GrassBlade> GrassBladesBuffer;
            float3 WindDirection;
            float WindForce;

            Varyings vert (Attributes IN, uint vertex_id: SV_VERTEXID, uint instance_id: SV_INSTANCEID)
            {
                Varyings OUT;

                // position vertex for GPU instancing ---------------------------------------------------

                GrassBlade grassBlade;
                OUT.positionHCS = positionGrassVertexInHClipPos(
                    GrassBladesBuffer,
                    instance_id,
                    grassBlade,
                    IN.positionOS,
                    IN.uv,
                    WindDirection,
                    WindForce
                );

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDCG
        }
    }
}
