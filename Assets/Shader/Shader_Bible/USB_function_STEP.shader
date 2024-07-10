Shader "Unlit/USB_function_STEP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(Step, SmoothStep)] _StepMode ("Step Mode", Float) = 0
        _Smooth ("Smooth", Range(0.1, 10)) = 0.1
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
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature_local _STEPMODE_STEP _STEPMODE_SMOOTHSTEP

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Smooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // add the color edge
                float edge = 0.5;
                // add the amount of interpolation
                float smooth = _Smooth;
                // let’s return to RGB color
                fixed3 sstep = 0;

                #if defined(_STEPMODE_STEP)
                    sstep = step (i.uv.y, edge);
                #elif defined(_STEPMODE_SMOOTHSTEP)
                    sstep = smoothstep((i.uv.y - smooth), (i.uv.y + smooth), edge);
                #endif
                // fixed4 col = tex2D (_MainTex, i.uv);
                return fixed4(sstep, 1);
            }
            ENDCG
        }
    }
}
