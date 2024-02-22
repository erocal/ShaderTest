
Shader "FakeLight/Diffuse/BumpTexture"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpTex("BumpMap", 2D) = "white" {}
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

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			uniform sampler2D _BumpTex;
			uniform half4 _BumpTex_ST;

			uniform float4 _FakeLightDir;
			uniform float4 _FakeLightColor;

			struct vertexIN_base
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct v2f_base
			{
				float4 pos : SV_POSITION;
				half4  uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				UNITY_FOG_COORDS(4)
			};

			v2f_base vert(vertexIN_base v)
			{
				v2f_base o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

				// establish tangent space
				float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				o.lightDir = mul(unity_WorldToObject, -_FakeLightDir).xyz;
				o.lightDir = mul(rotation, o.lightDir);

				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag(v2f_base i) : COLOR
			{
				float4 packedN = tex2D(_BumpTex, i.uv.zw);
				float3 tangentN = UnpackNormal(packedN);
				i.lightDir = normalize(i.lightDir);
				tangentN = normalize(tangentN);

				float diffuse = max(0, dot(tangentN, i.lightDir));

				fixed4 mainColor = tex2D(_MainTex, i.uv) * _Color;
				fixed4 clr = mainColor * _FakeLightColor * min(diffuse + 0.2, 1);

				UNITY_APPLY_FOG(i.fogCoord,clr);

				return clr;
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			//讓陰影重疊融合
			Stencil
			{
				Ref 2
				Comp NotEqual
				Pass Replace
			}

			//使陰影在平面之上  
			Offset -1,-1

			Blend DstColor SrcColor

			CGPROGRAM
			#pragma vertex vert   
			#pragma fragment frag  
			#include "UnityCG.cginc"  
			float4x4 _World2Ground;
			float4x4 _Ground2World;

			uniform float4 _FakeLightDir;

			float4 vert(float4 vertex: POSITION) : SV_POSITION
			{
				float3 litDir = _FakeLightDir.xyz;//讀取假光源
				litDir = mul(_World2Ground,float4(litDir,0)).xyz;//把光源方向轉到接收平面空間
				litDir = normalize(litDir);

				float4 vt;
				vt = mul(unity_ObjectToWorld, vertex);
				vt = mul(_World2Ground,vt);//將物體頂點座標轉到接收平面空間
				vt.xz = vt.xz - (vt.y / litDir.y)*litDir.xz;//用三角型相似計算言光源方向投射後的xz  
				vt.y = 0.1;//使陰影保持在接收平面上  
				vt = mul(_Ground2World,vt);//用接收面的世界座標空間
				vt = mul(unity_WorldToObject,vt);//最後計算物件座標空間 

				return UnityObjectToClipPos(vt);//用MVP轉換輸出到Clip Space  
			}

			float4 frag(void) : COLOR
			{
				return float4(0.35,0.35,0.35,1);//陰影顏色
			}
			ENDCG
		}
	}
	FallBack Off
}