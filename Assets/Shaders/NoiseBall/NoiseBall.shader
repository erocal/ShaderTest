Shader "VertexTransformation/NoiseBall"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HideInInspector]_Radius ("Radius", Float) = 1
        _NoiseAmplitude ("Noise Amplitude", Float) = .12
        _NoiseFrequency ("Noise Frequency", Float) = .6
        _NoiseMotion ("Noise Motion", Float) = .4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard vertex:vert nolightmap addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Assets\ThirdParty\NoiseBall\NoiseBall\Shader\Common.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float dummy;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _NoiseMotion;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v)
        {
            _NoiseOffset += float3(0.13f, 0.82f, 0.11f) * _NoiseMotion * _Time.y;

            float3 v1 = displace(v.vertex.xyz);
            float3 v2 = displace(v.texcoord.xyz);
            float3 v3 = displace(v.texcoord1.xyz);
            v.vertex.xyz = v1;
            //v.normal = normalize(cross(v2 - v1, v3 - v1));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
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
