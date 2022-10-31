Shader "Unlit/GrassBlade_Lambert"
{
    Properties
    {
    }
    SubShader
    {
        // Tags { "IgnoreProjector"="True" "RenderType"="Grass" "DisableBatching"="True"}}

        Pass
        {
            Tags {"RenderType" = "Opaque"}
            // Tags {"LightMode" = "ForwardBase"}

            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

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
                SHADOW_COORDS(1)
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

                // get the instanced grass blade
                GrassBlade grassBlade = GrassBladesBuffer[instance_id];

                float4 worldPosition = positionVertexInWorld(grassBlade, IN.positionOS);
                worldPosition = applyWind(grassBlade, IN.uv, worldPosition, WindDirection, WindForce);

                // translate the world pos to clip pos
                OUT.pos = UnityWorldToClipPos(worldPosition);

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

            ColorMask 0

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
            half4 YoungGrassColor;
            half4 OldGrassColor;

            Varyings vert (Attributes IN, uint vertex_id: SV_VERTEXID, uint instance_id: SV_INSTANCEID)
            {
                Varyings OUT;

                // get the instanced grass blade
                GrassBlade grassBlade = GrassBladesBuffer[instance_id];

                float4 worldPosition = positionVertexInWorld(grassBlade, IN.positionOS);
                worldPosition = applyWind(grassBlade, IN.uv, worldPosition, WindDirection, WindForce);

                // translate the world pos to clip pos
                OUT.positionHCS = UnityWorldToClipPos(worldPosition);

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
