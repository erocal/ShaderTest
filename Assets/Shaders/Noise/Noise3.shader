Shader "Unlit/Noise3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            // 2D Noise based on Morgan McGuire @morgan3d
            // https://www.shadertoy.com/view/4dS3Wd
            float noise (in fixed2 st) {
                fixed2 i = floor(st);
                fixed2 f = frac(st);

                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + fixed2(1.0, 0.0));
                float c = random(i + fixed2(0.0, 1.0));
                float d = random(i + fixed2(1.0, 1.0));

                // Smooth Interpolation

                // Cubic Hermine Curve.  Same as SmoothStep()
                fixed2 u = f*f*(3.0-2.0*f);
                // u = smoothstep(0.,1.,f);

                // Mix 4 coorners percentages
                return lerp(a, b, u.x) +
                        (c - a)* u.y * (1.0 - u.x) +
                        (d - b) * u.x * u.y;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

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

                // Scale the coordinate system to see
                // some noise in action
                fixed2 pos = fixed2(i.uv*_Time.y);

                // Use the noise function
                float n = noise(pos);

                return fixed4(n, n, n, 1);
            }
            ENDCG
        }
    }
}
