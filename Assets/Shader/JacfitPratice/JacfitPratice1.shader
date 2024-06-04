Shader "JacfitPratice/JacfitPratice1"
{
    Properties
    {
        _Color ("Example Colour", Color) = (1,1,1,1)
        _Normal ("Example Normal", Color) = (1,1,1,1)
        _Emission ("Example Emission", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard Lambert

        struct Input
        {
            fixed4 _Color;
            fixed4 _Normal;
            fixed4 _Emission;
        };

        fixed4 _Color;
        fixed4 _Normal;
        fixed4 _Emission;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = _Color;
            o.Albedo = c.rgb;
            o.Normal = _Normal.rgb;
            o.Emission = _Emission.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
