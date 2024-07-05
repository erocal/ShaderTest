Shader "Unlit/Noise4"
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

            fixed2 random2(fixed2 st)
            {
                st = fixed2( dot(st,fixed2(127.1,311.7)),
                        dot(st,fixed2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            // Gradient Noise by Inigo Quilez - iq/2013
            // https://www.shadertoy.com/view/XdXGW8
            float noise(fixed2 st) 
            {
                fixed2 i = floor(st);
                fixed2 f = frac(st);

                fixed2 u = f*f*(3.0-2.0*f);

                return lerp( lerp( dot( random2(i + fixed2(0.0,0.0) ), f - fixed2(0.0,0.0) ),
                                dot( random2(i + fixed2(1.0,0.0) ), f - fixed2(1.0,0.0) ), u.x),
                            lerp( dot( random2(i + fixed2(0.0,1.0) ), f - fixed2(0.0,1.0) ),
                                dot( random2(i + fixed2(1.0,1.0) ), f - fixed2(1.0,1.0) ), u.x), u.y);
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
                fixed2 pos = fixed2(i.uv*20);

                fixed noi = noise(pos)*.5+.5;

                // Use the noise function
                fixed3 color = fixed3( noi, noi, noi );

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
