Shader "Holistic/OwnedBasicBlinn"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Geometry" }

        CGPROGRAM
        #pragma surface surf BasicBlinn

        /// lightDir ���Ӧ۪�����V
        /// viewDir �[��̤�V
        /// atten �I��� ����L��L���骺�j�׷l��
        half4 LightingBasicBlinn (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 h = normalize (lightDir + viewDir); // halfway

            half diff = max (0, dot (s.Normal, lightDir)); // diffuse

            float nh = max (0, dot (s.Normal, h)); // nh ���k�u�M��h���Ȥ������I�n�C
            float spec = pow  (nh, 48.0); // 48�O�]��Unity��48

            half4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
            c.a = s.Alpha;
            return c;
        }

        float4 _Colour;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Colour.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
