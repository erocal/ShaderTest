Shader "Unlit/Noise2"
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

            fixed2 truchetPattern(in fixed2 _st, in float _index)
            {
                _index = frac(((_index-0.5)*2.0));
                if (_index > 0.75) {
                    _st = fixed2(1.0, 1.0) - _st;
                } else if (_index > 0.5) {
                    _st = fixed2(1.0-_st.x,_st.y);
                } else if (_index > 0.25) {
                    _st = 1.0-fixed2(1.0-_st.x,_st.y);
                }
                return _st;
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
                i.uv = (i.uv-fixed2(5, 5))*(abs(sin(_Time.y*0.2))*5.);
                i.uv.x += _Time.y*3.0;

                fixed2 ipos = floor(i.uv);  // get the integer coords
                fixed2 fpos = frac(i.uv);  // get the fractional coords

                fixed2 tile = truchetPattern(fpos, random( ipos ));

                float color = 0.0;

                // Maze
                color = smoothstep(tile.x-0.3,tile.x,tile.y)-
                        smoothstep(tile.x,tile.x+0.3,tile.y);

                // Circles
                // color = (step(length(tile),0.6) -
                //          step(length(tile),0.4) ) +
                //         (step(length(tile-fixed2(1, 1)),0.6) -
                //          step(length(tile-fixed2(1, 1)),0.4) );

                // Truchet (2 triangles)
                // color = step(tile.x,tile.y);

                return fixed4(color, color, color, 1);
            }
            ENDCG
        }
    }
}
