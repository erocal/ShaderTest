Shader "Holistic/Hologram"
{
    Properties
    {
        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 0)
        _RimPower ("Rim Power", Range(0.5, 8)) = 7.5
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}

        Pass {
            ZWrite On // �g�J�`�׸��
            ColorMask 0 // �����g�J���󤺮e�AColorMask�O���C��q�D�i��B�n�A�����Ϊk : ColorMask RGB
        }

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        struct Input
        {
            float3 viewDir;
        };

        float4 _RimColor;
        float _RimPower;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = _RimColor.rgb * pow(rim, _RimPower) * 10;
            o.Alpha = pow(rim, _RimPower);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
