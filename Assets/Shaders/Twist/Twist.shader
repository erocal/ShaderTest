// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Twist/Twist"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TwistStrength ("旋轉力道", Range(0, 10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _TwistStrength;

            v2f vert (appdata v)
            {
                v2f o;

                //o.vertex = UnityObjectToClipPos(v.vertex);

                //float4 wpos = mul(unity_ObjectToWorld, v.vertex);

                float4 wpos = v.vertex;

                float s = sin(_TwistStrength * wpos.y);
                float c = cos(_TwistStrength * wpos.y);

                float2x2 rot = float2x2(c, -s, s, c);
                wpos.xz = mul(rot, wpos.xz);

                o.vertex = UnityObjectToClipPos(wpos);

                o.color = v.color;
                o.uv = v.uv;
                o.normal = v.normal;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
