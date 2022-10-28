Shader "Unlit/TerrainUnlit"
{
    Properties
    {
        _TerrainColor ("Terrain Color", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _TerrainColor;
            float4 _TerrainColor_ST;
            sampler2D _HeightMap;
            float4 _HeightMap_ST;
            half4 _Color;

            Varyings vert (Input IN)
            {
                Varyings OUT;

                float2 uv_Height = TRANSFORM_TEX(IN.uv, _HeightMap);
                float4 heighPixel = tex2Dlod(_HeightMap, float4(uv_Height, 0.0, 0.0));
                float4 displacement = float4(0, 0, heighPixel.x, 0);

                IN.positionOS += displacement;

                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS);

                OUT.uv = TRANSFORM_TEX(IN.uv, _TerrainColor);
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                return tex2D(_TerrainColor, IN.uv);
            }
            ENDCG
        }
    }
}
