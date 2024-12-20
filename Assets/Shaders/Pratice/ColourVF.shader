Shader "Holistic/ColourVF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.color.r = (v.vertex.x+10)/10; // 世界空間xz
                //o.color.g = (v.vertex.z+10)/10;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 col = i.color;
                fixed4 col = i.color;
                col.r = i.vertex.x/1000; // 螢幕空間xy
                col.g = i.vertex.y/1000;
                return col;
            }
            ENDCG
        }
    }
}
