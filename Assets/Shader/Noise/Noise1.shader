Shader "Unlit/Noise1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Slider ("Slider", Float) = 0
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float random (fixed2 st) 
            {
                return frac(sin(dot(st.xy,
                                    fixed2(12.9898,78.233)))*
                    43758.5453123);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Slider;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                i.uv *= 10.0; // Scale the coordinate system by 10
                fixed2 ipos = floor(i.uv);  // get the integer coords
                fixed2 fpos = frac(i.uv);  // get the fractional coords

                fixed rnd = random( ipos );

                fixed3 color = fixed3(rnd, rnd, rnd);

                color = fixed3(fpos,_Slider);

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
