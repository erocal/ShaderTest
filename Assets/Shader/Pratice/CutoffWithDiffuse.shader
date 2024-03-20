Shader "Holistic/CutoffWithDiffuse"
{
    Properties
    {
        _myDiffuse ("Diffuse Texture", 2D) = "white" {}
        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 0)
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
        _StripeWidth ("StripeWidth ", Range(0, 20)) = 10
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _myDiffuse;

        struct Input
        {
            float2 uv_myDiffuse;
            float3 viewDir;
            float3 worldPos;
        };

        float4 _RimColor;
        float _RimPower;
        float _StripeWidth;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));

            o.Albedo = tex2D(_myDiffuse, IN.uv_myDiffuse).rgb;
            o.Emission = frac((IN.worldPos.y * _StripeWidth)) > 0.4 ? float3(0, 1, 0)*rim : _RimColor.rgb * pow(rim, _RimPower);
        }
        ENDCG
    }
    FallBack "Diffuse"
}

