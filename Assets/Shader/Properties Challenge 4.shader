Shader "Holistic/PropertiesChallenge4"
{
    Properties
    {
        _MainTex ("Diffuse texture", 2D) = "white" {}
        _EmissiveTex ("Emissive texture", 2D) = "white" {}
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        sampler2D _EmissiveTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_EmissiveTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            float4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            o.Emission = tex2D (_EmissiveTex, IN.uv_EmissiveTex).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
