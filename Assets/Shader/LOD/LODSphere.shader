Shader "Custom/LODSphere"
{
    Properties
    {

        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 0)
        _RimPower ("Rim Power", Range(0.5, 8)) = 7.5

        _Colour ("Colour", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white"{}

        _Tint("Colour Tint", Color) = (1, 1, 1, 1)
        _Speed("Speed", Range(0, 100)) = 10
        _Scale1("Scale 1", Range(0.1, 10)) = 2
        _Scale2("Scale 2", Range(0.1, 10)) = 2
        _Scale3("Scale 3", Range(0.1, 10)) = 2
        _Scale4("Scale 4", Range(0.1, 10)) = 2

    }

    SubShader
    {
        Tags{"Queue" = "Transparent"}
        LOD 300

        Pass {
            ZWrite On
            ColorMask 0 
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

    SubShader
    {

        LOD 200

        CGPROGRAM
        #pragma surface surf ToonRamp

        float4 _Colour;
        sampler2D _RampTex;

        half4 LightingToonRamp (SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            float diff = dot (s.Normal, lightDir);
            float h = diff * 0.5 + 0.5;

            float2 rh = h;
            float3 ramp = tex2D(_RampTex, rh).rgb;

            float4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (ramp);
            c.a = s.Alpha;
            return c;
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Colour.rgb;
        }
        ENDCG
    }

    SubShader
    {
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
                float4 vertexColor: COLOR0;
            };

            float4 _Tint;
            float _Speed;
            float _Scale1;
            float _Scale2;
            float _Scale3;
            float _Scale4;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                const float PI = 3.14159265;
                float t = _Time.x * _Speed;
                
                fixed4 col;

                //these are screen coordinates so
	            //get them down to small values for the
	            //sin to use
	            float xpos = i.vertex.x * 0.01;
	            float ypos = i.vertex.y * 0.01;

                // vertical
                float c = sin(xpos * _Scale1 + t);

                // horizontal
                c += sin(ypos * _Scale2 + t);

                // diagonal
                c += sin(_Scale3 * (xpos * sin(t/2.0) + 
                ypos * cos(t/3.0)) + t);

                // circular
                float c1 = pow(xpos + 0.5 * sin(t/5), 2);
                float c2 = pow(ypos + 0.5 * cos(t/5), 2);
                c += sin(sqrt(_Scale4 * (c1 + c2) + 1 + t));

                col.r = sin(c/4.0*PI);
                col.g = sin(c/4.0*PI + 2*PI/4);
                col.b = sin(c/4.0*PI + 4*PI/4);
                col.rgb += _Tint;

                return col;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
