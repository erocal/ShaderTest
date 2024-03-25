Shader "Holistic/BasicBlinnChanllenge"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _SpecColor("Specular Colour", Color) = (1,1,1,1)
        _Spec("Specular", Range(0, 1)) = 0.5
        _Gloss("Gloss", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Geometry" }

        CGPROGRAM
        #pragma surface surf BlinnChanllenge

        /// lightDir 光來自的光方向
        /// viewDir 觀察者方向
        /// atten 衰減值 光穿過其他物體的強度損失
        half4 LightingBlinnChanllenge (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 h = normalize (lightDir + viewDir); // halfway

            half diff = max (0, dot (s.Normal, lightDir)); // diffuse

            float nh = max (0, dot (s.Normal, h)); // nh 表面法線和“h”值之間的點積。
            float spec = pow  (nh, 48.0); // 48是因為Unity用48

            half4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * _SinTime;
            c.a = s.Alpha;
            return c;
        }

        float4 _Colour;
        half _Spec;
        fixed _Gloss;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Colour.rgb;
            o.Specular = _Spec;
            o.Gloss = _Gloss;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
