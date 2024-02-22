Shader "FakeLight/Diffuse/Texture_Transparent"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_MainLightColor("MainLightColor", Color) = (1,1,1,1)
		_MainLightDir("MainLightDir", Vector) = (1,1,0,0)
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		ZWrite On
		ZTest LEqual

		Pass
		{
			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			float4 _Color;
			float4 _MainLightColor;
			float4 _MainLightDir;

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			struct vertexIN_base
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f_base
			{
				float4 pos : SV_POSITION;
				half2  uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				UNITY_FOG_COORDS(4)
			};

			v2f_base vert(vertexIN_base v)
			{
				v2f_base o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = v.normal;

				o.lightDir = mul(unity_WorldToObject, _MainLightDir).xyz;

				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag(v2f_base i) : COLOR
			{
				i.lightDir = normalize(i.lightDir);
				i.normal = normalize(i.normal);

				float diffuse = max(0, dot(i.normal, i.lightDir));

				fixed4 mainColor = tex2D(_MainTex, i.uv) * _Color;
				fixed4 clr = mainColor * _MainLightColor * min(diffuse + 0.2, 1);

				clr.a = mainColor.a;

				UNITY_APPLY_FOG(i.fogCoord,clr);

				return clr;
			}
			ENDCG
		}
	}
	FallBack Off
}