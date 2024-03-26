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
            ZWrite On // 寫入深度資料
            ColorMask 0 // 但不寫入任何內容，ColorMask是對顏色通道進行遮罩，類似用法 : ColorMask RGB
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
