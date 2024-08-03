Shader "Custom/ColorGradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Angle ("Angle", Range(0, 360)) = 0
        [HideInInspector]_GradientTex ("Gradient Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="AlphaTest"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #define DEGREE_2_RADIAN 0.01745329252
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "cginc_gradient_helper.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_GradientTex : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_GradientTex : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GradientTex;
            float4 _GradientTex_ST;
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_GradientTex = TRANSFORM_TEX(v.uv_GradientTex, _GradientTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);



                fixed4 gradientCol = tex2D(_GradientTex, rotateUV(i.uv_GradientTex, _Angle));
                return col * gradientCol;
            }
            ENDCG
        }
    }
}
