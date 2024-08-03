Shader "Custom/FadeInOut"
{
    Properties
    {
        _Inverse("Inverse", int) = 0
        _MainTex("Texture", 2D) = "white" {}
        _MainColor("MainColor", Color) = (1,1,1,1)
        _FadeNear("fade near distance", float) = 10
        _FadeFar("Fade far", float) = 20
        _FadeRate("Fade Rate", Range(0.001, 2)) = 0.1
        _AlphaValue("_AlphaValue", Range(0.01, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        Cull back
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : NORMAL;
            };

            float _AlphaValue;
            int _Inverse;
            float4 _MainColor;
            float _FadeRate;
            float _FadeNear;
            float _FadeFar;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                float3 posView = UnityObjectToViewPos(v.vertex); 
                float distance = length(posView);
                if(_Inverse == 0)
                {
                    o.fade = saturate((distance - _FadeNear) / (_FadeFar - _FadeNear)) * _FadeRate;
                }
                else
                {
                    o.fade = 1 - saturate((distance + _FadeNear) / (_FadeFar + _FadeNear));
                }
                return o;
            }
            float4 frag(v2f i) : COLOR
            {
                float4 col = tex2D(_MainTex,i.uv) * _MainColor;
                half normalAngle = 1 - abs(dot(i.worldNormal, i.viewDir));
                return float4(col.rgb, col.a * i.fade) * normalAngle;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
