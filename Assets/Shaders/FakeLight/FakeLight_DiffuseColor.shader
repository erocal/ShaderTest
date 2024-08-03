Shader "FakeLight/Diffuse/Color"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainLightColor("MainLightColor", Color) = (1,1,1,1)
		_MainLightDir("MainLightDir", Vector) = (1,1,0,0)
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 200

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Lighting Off

			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			float4 _Color;
			float4 _MainLightColor;
			float4 _MainLightDir;

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

				fixed4 mainColor = _Color;
				fixed4 clr = mainColor * _MainLightColor * min(diffuse + 0.2, 1);

				UNITY_APPLY_FOG(i.fogCoord,clr);

				return clr;
			}
			ENDCG
		}
	}
	FallBack Off
}