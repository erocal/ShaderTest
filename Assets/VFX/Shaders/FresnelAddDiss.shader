// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/FresnelAddDiss"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		_FresnelScale("FresnelScale", Float) = 1
		_FresnelPower("FresnelPower", Float) = 5
		_MainTexture("MainTexture ", 2D) = "white" {}
		[Toggle]_UseEmissionTex("UseEmissionTex", Float) = 0
		[Toggle]_UseCustomDataTex1Offsetxy("UseCustomData:Tex1Offset(x,y)", Float) = 0
		_EmissionTexture("EmissionTexture", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,1)
		_EmissionTexPower("EmissionTexPower", Float) = 0
		_EmissionSpeed("EmissionSpeed", Vector) = (0,0,0,0)
		_DissolveColor("DissolveColor ", Color) = (0,0,0,0)
		_DissolveTexture("DissolveTexture", 2D) = "white" {}
		[KeywordEnum(Key1,Key2,Key3,Key4,Key5)] _DissolveRange("DissolveRange", Float) = 0
		_DissolveRange_Key1("DissolveRange_Key1", Float) = 0.8050427
		_DissolveRange_Key2("DissolveRange_Key2", Float) = 0.8050427
		_DissolveRange_Key3("DissolveRange_Key3", Float) = 0.8050427
		_DissolveRange_Key4("DissolveRange_Key4", Float) = 0.8050427
		_DissolveRange_Key5("DissolveRange_Key5", Float) = 0.8050427
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off 
			ZWrite On
			ZTest LEqual
			
			Pass {
			
				CGPROGRAM
				
				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"
				#define ASE_NEEDS_FRAG_COLOR
				#pragma shader_feature_local _DISSOLVERANGE_KEY1 _DISSOLVERANGE_KEY2 _DISSOLVERANGE_KEY3 _DISSOLVERANGE_KEY4 _DISSOLVERANGE_KEY5


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					float3 ase_normal : NORMAL;
					float4 ase_texcoord1 : TEXCOORD1;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
					float4 ase_texcoord5 : TEXCOORD5;
				};
				
				
				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				uniform float _FresnelScale;
				uniform float _FresnelPower;
				uniform float4 _MainColor;
				uniform float _EmissionTexPower;
				uniform sampler2D _EmissionTexture;
				uniform float2 _EmissionSpeed;
				uniform float4 _EmissionColor;
				uniform float _UseEmissionTex;
				uniform sampler2D _MainTexture;
				uniform float4 _MainTexture_ST;
				uniform float _UseCustomDataTex1Offsetxy;
				uniform float _DissolveRange_Key1;
				uniform float _DissolveRange_Key2;
				uniform float _DissolveRange_Key3;
				uniform float _DissolveRange_Key4;
				uniform float _DissolveRange_Key5;
				uniform sampler2D _DissolveTexture;
				uniform float4 _DissolveTexture_ST;
				uniform float4 _DissolveColor;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.ase_texcoord3.xyz = ase_worldPos;
					float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
					o.ase_texcoord4.xyz = ase_worldNormal;
					
					o.ase_texcoord5 = v.ase_texcoord1;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord3.w = 0;
					o.ase_texcoord4.w = 0;

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					float3 ase_worldPos = i.ase_texcoord3.xyz;
					float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
					ase_worldViewDir = normalize(ase_worldViewDir);
					float3 ase_worldNormal = i.ase_texcoord4.xyz;
					float fresnelNdotV92 = dot( ase_worldNormal, ase_worldViewDir );
					float fresnelNode92 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV92, _FresnelPower ) );
					float4 temp_cast_0 = (0.0).xxxx;
					float2 texCoord49 = i.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner50 = ( 1.0 * _Time.y * _EmissionSpeed + texCoord49);
					float4 lerpResult54 = lerp( temp_cast_0 , ( ( _EmissionTexPower * tex2D( _EmissionTexture, panner50 ).r ) * _EmissionColor ) , _UseEmissionTex);
					float2 uv_MainTexture = i.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
					float2 temp_cast_1 = (0.0).xx;
					float4 texCoord41 = i.ase_texcoord5;
					texCoord41.xy = i.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult104 = (float2(texCoord41.x , texCoord41.y));
					float2 lerpResult106 = lerp( temp_cast_1 , appendResult104 , _UseCustomDataTex1Offsetxy);
					#if defined(_DISSOLVERANGE_KEY1)
					float staticSwitch162 = _DissolveRange_Key1;
					#elif defined(_DISSOLVERANGE_KEY2)
					float staticSwitch162 = _DissolveRange_Key2;
					#elif defined(_DISSOLVERANGE_KEY3)
					float staticSwitch162 = _DissolveRange_Key3;
					#elif defined(_DISSOLVERANGE_KEY4)
					float staticSwitch162 = _DissolveRange_Key4;
					#elif defined(_DISSOLVERANGE_KEY5)
					float staticSwitch162 = _DissolveRange_Key5;
					#else
					float staticSwitch162 = _DissolveRange_Key1;
					#endif
					float2 uv_DissolveTexture = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float4 tex2DNode32 = tex2D( _DissolveTexture, uv_DissolveTexture );
					float temp_output_34_0 = step( staticSwitch162 , tex2DNode32.r );
					float temp_output_35_0 = step( staticSwitch162 , ( tex2DNode32.r + 0.05 ) );
					float4 appendResult61 = (float4(( ( fresnelNode92 * i.color * _MainColor ) + ( lerpResult54 + ( tex2D( _MainTexture, ( uv_MainTexture + lerpResult106 ) ) * temp_output_34_0 ) + ( _DissolveColor * ( temp_output_35_0 - temp_output_34_0 ) ) ) ).rgb , ( ( i.color.a * _MainColor.a ) * saturate( temp_output_35_0 ) )));
					

					fixed4 col = appendResult61;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1504.8;46.4;1536;607;3755.194;-184.397;3.714615;True;True
Node;AmplifyShaderEditor.CommentaryNode;112;-2817.542,-1453.501;Inherit;False;4276.15;3530.226;A;16;110;109;111;108;22;66;97;98;61;37;162;163;164;165;166;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;110;-2339.875,-192.3331;Inherit;False;1749.417;1018.638;主貼圖;8;106;104;107;41;67;78;105;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;109;-2767.542,-1403.501;Inherit;False;1944.88;608.5244;發光貼圖;11;54;56;5;6;53;50;4;75;74;49;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;53;-2717.542,-1087.586;Inherit;False;Property;_EmissionSpeed;EmissionSpeed;9;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-2710.914,-1259.339;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-2289.875,622.3051;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;111;-1458.543,1390.407;Inherit;False;1699.259;686.3181;溶解貼圖;8;32;39;36;35;34;38;102;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1898.265,651.6564;Inherit;False;Property;_UseCustomDataTex1Offsetxy;UseCustomData:Tex1Offset(x,y);5;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-2288.065,1804.973;Inherit;False;Property;_DissolveRange_Key5;DissolveRange_Key5;19;0;Create;True;0;0;0;False;0;False;0.8050427;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2291.694,1469.654;Inherit;False;Property;_DissolveRange_Key1;DissolveRange_Key1;15;0;Create;True;0;0;0;False;0;False;0.8050427;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-2294.012,1622.859;Inherit;False;Property;_DissolveRange_Key3;DissolveRange_Key3;17;0;Create;True;0;0;0;False;0;False;0.8050427;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1645.743,-982.215;Inherit;False;Constant;_Float3;Float 3;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-2285.167,1717.195;Inherit;False;Property;_DissolveRange_Key4;DissolveRange_Key4;18;0;Create;True;0;0;0;False;0;False;0.8050427;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1249.583,1938.163;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-2292.54,1543.264;Inherit;False;Property;_DissolveRange_Key2;DissolveRange_Key2;16;0;Create;True;0;0;0;False;0;False;0.8050427;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1400.925,1658.622;Inherit;True;Property;_DissolveTexture;DissolveTexture;13;0;Create;True;0;0;0;False;0;False;-1;None;6066e5a39fd0e724f8b9f3286e0c93b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;104;-1832.472,561.6609;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;50;-2466.059,-1205.372;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-2243.913,-1219.257;Inherit;True;Property;_EmissionTexture;EmissionTexture;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-2060.709,-142.3331;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;162;-1884.315,1467.743;Inherit;False;Property;_DissolveRange;DissolveRange;14;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;Key1;Key2;Key3;Key4;Key5;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-974.5752,1836.924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2132.735,-1353.501;Inherit;False;Property;_EmissionTexPower;EmissionTexPower;8;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;106;-1620.29,548.9758;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-1361.214,-135.7288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;5;-1628.644,-1253.435;Inherit;False;Property;_EmissionColor;EmissionColor;7;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,0.9392825,0.4198113,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1910.954,-1351.973;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;108;-207.5012,-1194.658;Inherit;False;1011.292;754.8118;光暈;7;90;89;91;93;92;95;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;35;-787.2075,1823.325;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;34;-837.9881,1536.557;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-157.5012,-868.4399;Inherit;False;Property;_FresnelPower;FresnelPower;2;0;Create;True;0;0;0;False;0;False;5;4.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1277.522,38.52032;Inherit;True;Property;_MainTexture;MainTexture ;3;0;Create;True;0;0;0;False;0;False;-1;None;3931eb9a76796994ca209d67755d8b03;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1412.333,-1274.815;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;102;-335.5627,1440.407;Inherit;False;Property;_DissolveColor;DissolveColor ;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-105.669,-1039.112;Inherit;False;Property;_FresnelScale;FresnelScale;1;0;Create;True;0;0;0;False;0;False;1;7.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1429.55,-910.3763;Inherit;False;Property;_UseEmissionTex;UseEmissionTex;4;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-315.1358,1656.905;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-825.8585,86.95897;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;78.31582,1597.047;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;93;91.69308,-648.8467;Inherit;False;Property;_MainColor;MainColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.7490196,0,0.4,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;91;39.56022,-871.1213;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;54;-1004.663,-1001.561;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;92;151.6925,-1144.658;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;-293.6939,675.6488;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;567.5908,-945.9889;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;604.8102,-679.3636;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;460.2713,901.5423;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;971.7479,-391.9617;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;884.225,240.3094;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;115;-1795.057,5377.064;Inherit;False;1699.259;686.3181;溶解貼圖;10;145;144;138;137;133;130;127;124;123;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;123;-1660.138,5645.278;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;6066e5a39fd0e724f8b9f3286e0c93b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;48;-1466.273,1233.73;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1745.057,5511.795;Inherit;False;Property;_Float4;Float 4;20;0;Create;True;0;0;0;False;0;False;0.8050427;2.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;133;-1164.718,5553.324;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1586.097,5924.819;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;-672.077,5427.064;Inherit;False;Property;_Color1;Color 1;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;61;1204.008,-390.4301;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-1311.089,5823.581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;-769.246,5634.957;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;130;-1386.585,5451.817;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;137;-1123.722,5809.981;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-258.1981,5583.704;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;101;2567.401,-452.211;Float;False;True;-1;2;ASEMaterialInspector;0;7;VFX/FresnelAddDiss;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;True;True;1;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Opaque=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;104;0;41;1
WireConnection;104;1;41;2
WireConnection;50;0;49;0
WireConnection;50;2;53;0
WireConnection;4;1;50;0
WireConnection;162;1;37;0
WireConnection;162;0;163;0
WireConnection;162;2;164;0
WireConnection;162;3;165;0
WireConnection;162;4;166;0
WireConnection;36;0;32;1
WireConnection;36;1;39;0
WireConnection;106;0;56;0
WireConnection;106;1;104;0
WireConnection;106;2;107;0
WireConnection;105;0;78;0
WireConnection;105;1;106;0
WireConnection;74;0;75;0
WireConnection;74;1;4;1
WireConnection;35;0;162;0
WireConnection;35;1;36;0
WireConnection;34;0;162;0
WireConnection;34;1;32;1
WireConnection;1;1;105;0
WireConnection;6;0;74;0
WireConnection;6;1;5;0
WireConnection;38;0;35;0
WireConnection;38;1;34;0
WireConnection;67;0;1;0
WireConnection;67;1;34;0
WireConnection;21;0;102;0
WireConnection;21;1;38;0
WireConnection;54;0;56;0
WireConnection;54;1;6;0
WireConnection;54;2;55;0
WireConnection;92;2;90;0
WireConnection;92;3;89;0
WireConnection;22;0;35;0
WireConnection;94;0;92;0
WireConnection;94;1;91;0
WireConnection;94;2;93;0
WireConnection;95;0;91;4
WireConnection;95;1;93;4
WireConnection;66;0;54;0
WireConnection;66;1;67;0
WireConnection;66;2;21;0
WireConnection;98;0;94;0
WireConnection;98;1;66;0
WireConnection;97;0;95;0
WireConnection;97;1;22;0
WireConnection;48;1;41;3
WireConnection;133;0;130;0
WireConnection;133;1;123;1
WireConnection;61;0;98;0
WireConnection;61;3;97;0
WireConnection;127;0;123;1
WireConnection;127;1;121;0
WireConnection;138;0;137;0
WireConnection;138;1;133;0
WireConnection;130;0;124;0
WireConnection;137;0;130;0
WireConnection;137;1;127;0
WireConnection;145;0;144;0
WireConnection;145;1;138;0
WireConnection;101;0;61;0
ASEEND*/
//CHKSM=FB034CE1DD33984E8A1CB6979462896AB93DD313