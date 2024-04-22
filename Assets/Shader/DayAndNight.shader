Shader "Custom/DayAndNight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Sun Settings)]
		_SunColor("Sun Color", Color) = (1,1,1,1)
        _SunRadius("Sun Radius",  Range(0, 2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Background" "PreviewType"="Skybox" "Queue"="Background" }
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
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _SunRadius;
            float4 _SunColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sun
				float sun = distance(i.uv.xyz, _WorldSpaceLightPos0);
				float sunDisc = 1 - (sun / _SunRadius);
				sunDisc = saturate(sunDisc * 50);

                float3 Sun = sunDisc * _SunColor;

                return float4(Sun, 1);
            }
            ENDCG
        }
    }
}
