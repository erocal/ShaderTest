Shader "Outline/InnerOutline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_Alpha("General Alpha",  Range(0,1)) = 1
        _InnerOutlineColor("Inner Outline Color", Color) = (1,0,0,1)
		_InnerOutlineThickness("Outline Thickness",  Range(0,3)) = 1
		_InnerOutlineAlpha("Inner Outline Alpha",  Range(0,1)) = 1
		_InnerOutlineGlow("Inner Outline Glow",  Range(1,250)) = 4
        [Toggle(ONLYINNEROUTLINE_ON)] _ONLYINNEROUTLINE("Only Inner Outline",  Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "CanUseSpriteAtlas" = "True" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma shader_feature_local ONLYINNEROUTLINE_ON

            half _InnerOutlineThickness, _InnerOutlineAlpha, _InnerOutlineGlow;
			half4 _InnerOutlineColor;
            sampler2D _MainTex;
            half4 _MainTex_ST, _MainTex_TexelSize, _Color;
			half _Alpha;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				half4 color : COLOR;
            	UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				half4 color : COLOR;
            	UNITY_VERTEX_OUTPUT_STEREO 
            };

            half3 GetPixel(in int offsetX, in int offsetY, half2 uv, sampler2D tex)
			{
				return tex2D(tex, (uv + half2(offsetX * _MainTex_TexelSize.x, offsetY * _MainTex_TexelSize.y))).rgb;
			}

            v2f vert (appdata v)
            {
                v2f o;
            	UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half4 col = tex2D(_MainTex, i.uv);
				col *= i.color;

				half3 innerT = abs(GetPixel(0, _InnerOutlineThickness, i.uv, _MainTex) - GetPixel(0, -_InnerOutlineThickness, i.uv, _MainTex));
				innerT += abs(GetPixel(_InnerOutlineThickness, 0, i.uv, _MainTex) - GetPixel(-_InnerOutlineThickness, 0, i.uv, _MainTex));
				#if !ONLYINNEROUTLINE_ON
				innerT = (innerT / 2.0) * col.a * _InnerOutlineAlpha;
				col.rgb += length(innerT) * _InnerOutlineColor.rgb * _InnerOutlineGlow;
				#else
				innerT *= col.a * _InnerOutlineAlpha;
				col.rgb = length(innerT) * _InnerOutlineColor.rgb * _InnerOutlineGlow;
				col.a = step(0.3, col.r+col.g+col.b);
				#endif

                col *= _Color;
                col.a *= _Alpha;

                return col;
            }
            ENDCG
        }
    }
}
