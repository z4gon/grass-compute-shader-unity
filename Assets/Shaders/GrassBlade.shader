Shader "Custom/GrassBlade"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addshadow fullforwardshadows
        #pragma instancing_options procedural:setup

        #include "./shared/GrassBlade.cginc"
        #include "./shared/Transformations.cginc"

        #pragma target 5.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        half4 _Color;

        // #ifdef SHADER_API_D3D11
        //     StructuredBuffer<GrassBlade> GrassBladesBuffer;
        // #endif

        float4x4 _TranslationMatrix;
        float3 _Position;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v, out Input data)
        {
            // // #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            // float4 translatedVertex = mul(_TranslationMatrix, v.vertex);
            // v.vertex = translatedVertex;
            // // #endif
        }

        void setup()
        {
            // // #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            // GrassBlade grassBlade = GrassBladesBuffer[unity_InstanceID];
            // _Position = grassBlade.position;
            // _TranslationMatrix = getTranslation_Matrix(_Position);
            // // #endif
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
