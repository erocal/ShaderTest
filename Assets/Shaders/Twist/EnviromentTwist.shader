Shader "Twist/EnviromentTwist"
{
    Properties
    {
		[NoScaleOffset]_NoiseTex("Noise Texture", 2D) = "white" {}
		[NoScaleOffset]_NoiseMaskTex("Noise Mask", 2D) = "white" {}
		_NoiseScale("Noise Scale", Float) = 120
		_NoiseStrength("Noise Strength", Range(0, 1)) = 1
		_Speed("Speed", Float) = 1
    }
    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" "IgnoreProjector" = "True"  }
        LOD 100
		GrabPass{ "_TwistTex" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			float _NoiseScale;
			float _NoiseStrength;
			float _Speed;
			sampler2D _TwistTex;
			sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
			sampler2D _NoiseMaskTex;
            float4 _NoiseMaskTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
				float2 noiseUV : TEXCOORD1;
				float2 noiseMaskUV : TEXCOORD2;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 grabPos : TEXCOORD0;
				float2 noiseUV : TEXCOORD1;
				float2 noiseMaskUV : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.noiseUV = TRANSFORM_TEX(v.noiseUV, _NoiseTex);
				o.noiseMaskUV = TRANSFORM_TEX(v.noiseMaskUV, _NoiseMaskTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				i.noiseUV.y += _Time.y * _Speed;

				fixed4 noiseCol = tex2D(_NoiseTex, i.noiseUV / _NoiseScale);
				fixed4 noiseMaskCol = tex2D(_NoiseMaskTex, i.noiseMaskUV);

				noiseCol *= noiseMaskCol.a;

				fixed4 grabPlusNoisePos = i.grabPos ;
				grabPlusNoisePos.xy += noiseCol.xy;

				fixed4 mixPos = lerp(i.grabPos, grabPlusNoisePos, _NoiseStrength);

                // sample the texture
                fixed4 col = tex2Dproj(_TwistTex, mixPos);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
