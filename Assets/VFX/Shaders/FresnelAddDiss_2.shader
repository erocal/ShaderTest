// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/FresnelAddDiss_2"
{
	Properties
	{
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		_FresnelScale("FresnelScale", Float) = 1
		_FresnelPower("FresnelPower", Float) = 5
		_MainTexture("MainTexture ", 2D) = "white" {}
		[Toggle]_UseEmissionTex("UseEmissionTex", Float) = 0
		_EmissionTexture("EmissionTexture", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,1)
		_EmissionTexPower("EmissionTexPower", Float) = 0
		_EmissionSpeed("EmissionSpeed", Vector) = (0,0,0,0)
		[Toggle]_UseDissolveEdge("UseDissolveEdge", Float) = 0
		_Edge1("Edge(ori:0.1)", Float) = 0.01
		[HDR]_EdgeColor("EdgeColor ", Color) = (0.9811321,0.9811321,0.9811321,1)
		_EdgeRange("EdgeRange(x)", Float) = 0
		[Toggle]_UseDecorTex("UseDecorTex", Float) = 0
		_DecorativeTex("DecorativeTex", 2D) = "white" {}
		[HDR]_DecorColor("DecorColor", Color) = (1,1,1,1)
		_DecorTexPower("DecorTexPower", Float) = 0
		_DecorTexEmission("DecorTexEmission", Float) = 0
		_AllEmission("AllEmission", Float) = 0
		_DecorSpeed("DecorSpeed", Vector) = (0,0,0,0)
		[HDR]_DissolveColor("DissolveColor ", Color) = (0.9811321,0.9811321,0.9811321,1)
		_DissolveTexture("DissolveTexture", 2D) = "white" {}
		_DissolveRangey("DissolveRange(y)", Float) = 0.8050427
		[Toggle]_UseCustomData("UseCustomData", Float) = 0
		_FlowMap("FlowMap", 2D) = "white" {}
		_FlowMapSize("FlowMapSize", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "Queue"="AlphaTest" "RenderType"="Opaque"  }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _FresnelScale;
			uniform float _FresnelPower;
			uniform float4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform sampler2D _FlowMap;
			uniform float4 _FlowMap_ST;
			uniform float _FlowMapSize;
			uniform float _EdgeRange;
			uniform float _UseCustomData;
			uniform float _Edge1;
			uniform float _UseDissolveEdge;
			uniform float _DissolveRangey;
			uniform sampler2D _DissolveTexture;
			uniform float4 _DissolveTexture_ST;
			uniform float _EmissionTexPower;
			uniform sampler2D _EmissionTexture;
			uniform float2 _EmissionSpeed;
			uniform float4 _EmissionTexture_ST;
			uniform float4 _EmissionColor;
			uniform float _UseEmissionTex;
			uniform float4 _EdgeColor;
			uniform float _DecorTexPower;
			uniform sampler2D _DecorativeTex;
			uniform float2 _DecorSpeed;
			uniform float4 _DecorativeTex_ST;
			uniform float4 _DecorColor;
			uniform float _DecorTexEmission;
			uniform float _AllEmission;
			uniform float _UseDecorTex;
			uniform float4 _DissolveColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_color = v.color;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
				o.ase_texcoord3 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV92 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode92 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV92, _FresnelPower ) );
				float4 temp_output_94_0 = ( fresnelNode92 * i.ase_color * _MainColor );
				float2 uv_MainTexture = i.ase_texcoord2.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				float2 uv_FlowMap = i.ase_texcoord2.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float4 tex2DNode76 = tex2D( _FlowMap, uv_FlowMap );
				float2 appendResult77 = (float2(tex2DNode76.r , tex2DNode76.g));
				float2 lerpResult79 = lerp( uv_MainTexture , appendResult77 , _FlowMapSize);
				float2 texCoord7 = i.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float4 texCoord41 = i.ase_texcoord3;
				texCoord41.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult42 = lerp( _EdgeRange , texCoord41.x , _UseCustomData);
				float temp_output_8_0 = ( texCoord7.y + lerpResult42 );
				float temp_output_15_0 = ( 1.0 - step( temp_output_8_0 , ( 0.49 + _Edge1 ) ) );
				float lerpResult86 = lerp( 1.0 , temp_output_15_0 , _UseDissolveEdge);
				float lerpResult48 = lerp( _DissolveRangey , texCoord41.y , _UseCustomData);
				float2 uv_DissolveTexture = i.ase_texcoord2.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float4 tex2DNode32 = tex2D( _DissolveTexture, uv_DissolveTexture );
				float temp_output_34_0 = step( lerpResult48 , tex2DNode32.r );
				float4 temp_cast_0 = (0.0).xxxx;
				float2 uv2_EmissionTexture = i.ase_texcoord2.zw * _EmissionTexture_ST.xy + _EmissionTexture_ST.zw;
				float2 panner50 = ( 1.0 * _Time.y * _EmissionSpeed + uv2_EmissionTexture);
				float4 lerpResult54 = lerp( temp_cast_0 , ( ( _EmissionTexPower * tex2D( _EmissionTexture, panner50 ).r ) * _EmissionColor ) , _UseEmissionTex);
				float temp_output_14_0 = ( 1.0 - step( temp_output_8_0 , 0.49 ) );
				float lerpResult82 = lerp( 0.0 , ( temp_output_14_0 - temp_output_15_0 ) , _UseDissolveEdge);
				float4 temp_cast_1 = (0.0).xxxx;
				float2 uv_DecorativeTex = i.ase_texcoord2.xy * _DecorativeTex_ST.xy + _DecorativeTex_ST.zw;
				float2 panner68 = ( 1.0 * _Time.y * _DecorSpeed + uv_DecorativeTex);
				float4 lerpResult58 = lerp( temp_cast_1 , ( ( ( _DecorTexPower * tex2D( _DecorativeTex, panner68 ).r ) * _DecorColor * _DecorTexEmission ) + ( _DecorColor * _AllEmission ) ) , _UseDecorTex);
				float temp_output_35_0 = step( lerpResult48 , ( tex2DNode32.r + 0.05 ) );
				float temp_output_95_0 = ( i.ase_color.a * _MainColor.a );
				float lerpResult84 = lerp( 1.0 , saturate( temp_output_14_0 ) , _UseDissolveEdge);
				float temp_output_22_0 = saturate( ( lerpResult84 * temp_output_35_0 ) );
				float4 appendResult61 = (float4(( temp_output_94_0 + ( ( tex2D( _MainTexture, lerpResult79 ) * lerpResult86 * temp_output_34_0 ) + ( lerpResult54 + ( lerpResult82 * _EdgeColor ) + lerpResult58 ) + ( _DissolveColor * ( temp_output_35_0 - temp_output_34_0 ) ) ) ).rgb , ( temp_output_95_0 * temp_output_22_0 )));
				
				
				finalColor = appendResult61;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
78.4;73.6;1354;739;837.0314;991.1697;2.227189;True;True
Node;AmplifyShaderEditor.RangedFloatNode;9;-2600.59,561.348;Inherit;False;Property;_EdgeRange;EdgeRange(x);12;0;Create;False;0;0;0;False;0;False;0;4.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2744.988,898.6479;Inherit;False;Property;_UseCustomData;UseCustomData;23;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-2790.063,729.3374;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;70;-2523.459,1494.918;Inherit;False;Property;_DecorSpeed;DecorSpeed;19;0;Create;True;0;0;0;False;0;False;0,0;0,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-2540.173,1151.418;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;42;-2388.325,517.5468;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2577.325,382.6331;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-2110.118,648.1137;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;0.49;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2156.056,766.5097;Inherit;False;Property;_Edge1;Edge(ori:0.1);10;0;Create;False;0;0;0;False;0;False;0.01;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;53;-1951.533,-130.3688;Inherit;False;Property;_EmissionSpeed;EmissionSpeed;8;0;Create;True;0;0;0;False;0;False;0,0;0,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1942.743,-302.1221;Inherit;False;1;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;68;-2264.926,1331.058;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1952.117,635.1137;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-2174.672,394.2835;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-1918.165,1032.499;Inherit;True;Property;_DecorativeTex;DecorativeTex;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;50;-1667.426,-205.9351;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1777.961,961.1018;Inherit;False;Property;_DecorTexPower;DecorTexPower;16;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;10;-1788.258,419.5099;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;11;-1789.857,676.9488;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1249.583,1938.163;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1678.307,1584.516;Inherit;False;Property;_AllEmission;AllEmission;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1452.098,-105.0857;Inherit;True;Property;_EmissionTexture;EmissionTexture;5;0;Create;True;0;0;0;False;0;False;-1;None;f4dae3d18f11afa4084f7750cdc7055c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;76;-1827.641,-816.179;Inherit;True;Property;_FlowMap;FlowMap;24;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1598.214,965.2628;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1323.624,1658.622;Inherit;True;Property;_DissolveTexture;DissolveTexture;21;0;Create;True;0;0;0;False;0;False;-1;None;3a348ede641b82541a12a3c067d19b4f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;-1898.198,1364.764;Inherit;False;Property;_DecorColor;DecorColor;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.3867925,0,0.007349447,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1900.798,1536.365;Inherit;False;Property;_DecorTexEmission;DecorTexEmission;17;0;Create;True;0;0;0;False;0;False;0;1.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1408.543,1525.138;Inherit;False;Property;_DissolveRangey;DissolveRange(y);22;0;Create;True;0;0;0;False;0;False;0.8050427;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1415.442,-302.8508;Inherit;False;Property;_EmissionTexPower;EmissionTexPower;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-1572.393,664.1573;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-1578.789,422.7081;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-1050.071,1465.16;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-1547.673,-972.7014;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-1344.023,586.9767;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1438.532,1169.724;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1508.198,1433.664;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;-1501.575,-791.8336;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;5;-1416.209,120.2168;Inherit;False;Property;_EmissionColor;EmissionColor;6;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,0.9392825,0.4198113,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;-1562.985,-644.3658;Inherit;False;Property;_FlowMapSize;FlowMapSize;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-974.5752,1836.924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1091.046,1092.503;Inherit;False;Constant;_Float3;Float 3;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1158.31,727.1707;Inherit;False;Property;_UseDissolveEdge;UseDissolveEdge;9;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1235.695,-298.6898;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-994.7671,1336.53;Inherit;False;Property;_UseDecorTex;UseDecorTex;13;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1082.268,58.24749;Inherit;False;Property;_UseEmissionTex;UseEmissionTex;4;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1130.079,571.2711;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;34;-828.2042,1566.668;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;82;-898.2665,634.0227;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;35;-787.2075,1823.325;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;79;-1042.941,-578.3861;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;19;-1008.197,894.2829;Inherit;False;Property;_EdgeColor;EdgeColor ;11;1;[HDR];Create;True;0;0;0;False;0;False;0.9811321,0.9811321,0.9811321,1;5.210137,3.124526,1.400839,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;17;-1331.645,425.0913;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1085.719,-67.25723;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1046.609,1220.831;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-206.4124,-818.7357;Inherit;False;Property;_FresnelScale;FresnelScale;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;-868.6528,403.5553;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;-811.5051,1145.549;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;87;-641.7743,958.4898;Inherit;False;Property;_DissolveColor;DissolveColor ;20;1;[HDR];Create;True;0;0;0;False;0;False;0.9811321,0.9811321,0.9811321,1;5.210137,3.124526,1.400839,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;86;-871.0717,285.1342;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-899.006,-132.7337;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-454.3929,1751.793;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-258.2446,-648.0637;Inherit;False;Property;_FresnelPower;FresnelPower;2;0;Create;True;0;0;0;False;0;False;5;4.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-736.6041,729.5023;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-733.795,-182.6579;Inherit;True;Property;_MainTexture;MainTexture ;3;0;Create;True;0;0;0;False;0;False;-1;None;02daf0920e87bca45b5d3ad3ff44fc6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-145.0518,857.1843;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;91;-61.18314,-650.7451;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-470.2627,509.1117;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;93;-9.050323,-428.4705;Inherit;False;Property;_MainColor;MainColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1.498039,1.262745,0.07843138,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-407.7322,-165.406;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;92;50.949,-924.2822;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-239.8037,420.6408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;-46.69435,339.4551;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;504.0671,-458.9874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-155.2843,-39.85104;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;466.8476,-725.6127;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;971.7479,-391.9617;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;803.5878,96.96113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;88;701.4466,-638.553;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;1028.008,-125.4301;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;474.4094,10.74981;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;60;1379.694,-262.8599;Float;False;True;-1;2;ASEMaterialInspector;100;1;VFX/FresnelAddDiss;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;=;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;42;0;9;0
WireConnection;42;1;41;1
WireConnection;42;2;43;0
WireConnection;68;0;23;0
WireConnection;68;2;70;0
WireConnection;45;0;44;0
WireConnection;45;1;13;0
WireConnection;8;0;7;2
WireConnection;8;1;42;0
WireConnection;24;1;68;0
WireConnection;50;0;49;0
WireConnection;50;2;53;0
WireConnection;10;0;8;0
WireConnection;10;1;45;0
WireConnection;11;0;8;0
WireConnection;11;1;44;0
WireConnection;4;1;50;0
WireConnection;71;0;72;0
WireConnection;71;1;24;1
WireConnection;14;0;11;0
WireConnection;15;0;10;0
WireConnection;48;0;37;0
WireConnection;48;1;41;2
WireConnection;48;2;43;0
WireConnection;16;0;14;0
WireConnection;16;1;15;0
WireConnection;25;0;71;0
WireConnection;25;1;26;0
WireConnection;25;2;27;0
WireConnection;28;0;26;0
WireConnection;28;1;30;0
WireConnection;77;0;76;1
WireConnection;77;1;76;2
WireConnection;36;0;32;1
WireConnection;36;1;39;0
WireConnection;74;0;75;0
WireConnection;74;1;4;1
WireConnection;34;0;48;0
WireConnection;34;1;32;1
WireConnection;82;0;56;0
WireConnection;82;1;16;0
WireConnection;82;2;81;0
WireConnection;35;0;48;0
WireConnection;35;1;36;0
WireConnection;79;0;78;0
WireConnection;79;1;77;0
WireConnection;79;2;80;0
WireConnection;17;0;14;0
WireConnection;6;0;74;0
WireConnection;6;1;5;0
WireConnection;31;0;25;0
WireConnection;31;1;28;0
WireConnection;84;0;83;0
WireConnection;84;1;17;0
WireConnection;84;2;81;0
WireConnection;58;0;56;0
WireConnection;58;1;31;0
WireConnection;58;2;57;0
WireConnection;86;0;83;0
WireConnection;86;1;15;0
WireConnection;86;2;81;0
WireConnection;54;0;56;0
WireConnection;54;1;6;0
WireConnection;54;2;55;0
WireConnection;38;0;35;0
WireConnection;38;1;34;0
WireConnection;18;0;82;0
WireConnection;18;1;19;0
WireConnection;1;1;79;0
WireConnection;20;0;87;0
WireConnection;20;1;38;0
WireConnection;3;0;54;0
WireConnection;3;1;18;0
WireConnection;3;2;58;0
WireConnection;67;0;1;0
WireConnection;67;1;86;0
WireConnection;67;2;34;0
WireConnection;92;2;90;0
WireConnection;92;3;89;0
WireConnection;21;0;84;0
WireConnection;21;1;35;0
WireConnection;22;0;21;0
WireConnection;95;0;91;4
WireConnection;95;1;93;4
WireConnection;66;0;67;0
WireConnection;66;1;3;0
WireConnection;66;2;20;0
WireConnection;94;0;92;0
WireConnection;94;1;91;0
WireConnection;94;2;93;0
WireConnection;98;0;94;0
WireConnection;98;1;66;0
WireConnection;97;0;95;0
WireConnection;97;1;22;0
WireConnection;88;0;94;0
WireConnection;88;3;95;0
WireConnection;61;0;98;0
WireConnection;61;3;97;0
WireConnection;99;0;95;0
WireConnection;99;1;22;0
WireConnection;60;0;61;0
ASEEND*/
//CHKSM=9D355926BBDE67E61D985EC6479F1B9AAD111FA7