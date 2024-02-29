// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/Blend3_CenterGlow2"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[Header(ColorGradient)]_Emission("Emission", Float) = 2
		[Toggle]_UseCustomDataEmissionw("UseCustomData:Emission(w)", Float) = 0
		_MainScale("MainScale", Float) = 1
		_Alpha("Alpha", Float) = 1
		[Header(MainTex)][KeywordEnum(RGBA,A)] _Tex1UseAtext("Tex1UseAtext", Float) = 0
		_Main("Main", 2D) = "white" {}
		[Enum(GrayScale,0,Color_RGBA,1)]_MainTex_Color("MainTex_Color", Float) = 1
		[Toggle]_Tex1Offset_uv_Alpha_w1("UseCustomData:Tex1Offset(x,y)", Float) = 0
		[KeywordEnum(RGBA,A)] _Tex2UseAtext("Tex2UseAtext", Float) = 0
		_Tex2Value("Tex2Value", Float) = 1
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		[Header(DissTex)][Toggle]_UseDissolve("UseDissolve", Float) = 0
		_DissolveTexture("DissolveTexture ", 2D) = "white" {}
		_DissSpeedxy("DissSpeed(x,y)", Vector) = (0,0,0,0)
		_DissolvePower("DissolvePower", Range( 0 , 1)) = 1
		[Toggle]_TexOffset_uv_Alpha_w2("UseCustomData:DissolvePower(z)", Float) = 0
		[Enum(Hard_Diss,0,Soft_Diss,1)]_Diss_Mode("Diss_Mode", Float) = 0
		_Float3("硬邊溶解邊緣寬度", Range( 0 , 1)) = 1
		[HDR]_DissolveColor0("HardDissolveColor", Color) = (1,0,0.1231942,1)
		_DissolveVaule("Soft_DissolveVaule", Float) = 1
		_DissolveMaxValue("Soft_DissolveMaxValue", Float) = 1.5
		[Toggle]_Usecenterglow("Use center glow?", Float) = 0

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull [_CullMode]
			Lighting Off 
			ZWrite [_Zwrite]
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
				#pragma shader_feature_local _TEX1USEATEXT_RGBA _TEX1USEATEXT_A
				#pragma shader_feature_local _TEX2USEATEXT_RGBA _TEX2USEATEXT_A


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
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
				uniform float _Usecenterglow;
				uniform sampler2D _Main;
				uniform float4 _SpeedMainTexUVNoiseZW;
				uniform float _Tex1Offset_uv_Alpha_w1;
				uniform float4 _Main_ST;
				uniform float _MainTex_Color;
				uniform float _Tex2Value;
				uniform float _MainScale;
				uniform float _DissolvePower;
				uniform float _TexOffset_uv_Alpha_w2;
				uniform sampler2D _DissolveTexture;
				uniform float4 _DissSpeedxy;
				uniform float4 _DissolveTexture_ST;
				uniform float _Float3;
				uniform float4 _DissolveColor0;
				uniform float _Diss_Mode;
				uniform float _UseDissolve;
				uniform float _Emission;
				uniform float _UseCustomDataEmissionw;
				uniform float _DissolveVaule;
				uniform float _DissolveMaxValue;
				uniform float _Alpha;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.ase_texcoord3 = v.ase_texcoord1;

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

					float4 temp_cast_0 = ((0)).xxxx;
					float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
					float Const_0374 = 0.0;
					float2 temp_cast_1 = (Const_0374).xx;
					float4 texCoord111 = i.ase_texcoord3;
					texCoord111.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult113 = (float2(texCoord111.x , texCoord111.y));
					float2 lerpResult151 = lerp( temp_cast_1 , appendResult113 , _Tex1Offset_uv_Alpha_w1);
					float2 uv_Main = i.texcoord.xy * _Main_ST.xy + _Main_ST.zw;
					float2 panner107 = ( 1.0 * _Time.y * appendResult21 + ( lerpResult151 + uv_Main ));
					float4 tex2DNode13 = tex2D( _Main, panner107 );
					float4 lerpResult292 = lerp( temp_cast_0 , tex2DNode13 , _MainTex_Color);
					float Const_1376 = 1.0;
					float4 temp_cast_2 = (Const_1376).xxxx;
					float4 temp_output_371_0 = saturate( ( tex2DNode13 * _Tex2Value ) );
					float4 lerpResult256 = lerp( tex2DNode13 , temp_cast_2 , temp_output_371_0);
					float4 MainTex360 = ( lerpResult292 * lerpResult256 * i.color * _MainScale );
					float UV2_Z262 = texCoord111.z;
					float lerpResult215 = lerp( _DissolvePower , UV2_Z262 , _TexOffset_uv_Alpha_w2);
					float temp_output_246_0 = ( 1.0 - lerpResult215 );
					float temp_output_248_0 = (0.0 + (temp_output_246_0 - 0.0) * (1.5 - 0.0) / (1.0 - 0.0));
					float2 appendResult320 = (float2(_DissSpeedxy.x , _DissSpeedxy.y));
					float2 uv_DissolveTexture = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float2 panner322 = ( 1.0 * _Time.y * appendResult320 + uv_DissolveTexture);
					float DissTex_R345 = tex2D( _DissolveTexture, panner322 ).r;
					float temp_output_237_0 = step( temp_output_248_0 , ( DissTex_R345 + (0.0 + (_Float3 - 0.0) * (0.48 - 0.0) / (1.0 - 0.0)) ) );
					float temp_output_238_0 = ( temp_output_237_0 - step( temp_output_248_0 , DissTex_R345 ) );
					float4 lerpResult225 = lerp( MainTex360 , ( MainTex360 * temp_output_238_0 * _DissolveColor0 ) , temp_output_238_0);
					float4 lerpResult355 = lerp( lerpResult225 , MainTex360 , _Diss_Mode);
					float4 lerpResult231 = lerp( MainTex360 , lerpResult355 , _UseDissolve);
					float UV2_W263 = texCoord111.w;
					float lerpResult279 = lerp( _Emission , UV2_W263 , _UseCustomDataEmissionw);
					float4 temp_cast_3 = (tex2DNode13.a).xxxx;
					#if defined(_TEX1USEATEXT_RGBA)
					float4 staticSwitch182 = tex2DNode13;
					#elif defined(_TEX1USEATEXT_A)
					float4 staticSwitch182 = temp_cast_3;
					#else
					float4 staticSwitch182 = tex2DNode13;
					#endif
					float4 temp_cast_4 = (saturate( ( 0.0 * _Tex2Value ) )).xxxx;
					#if defined(_TEX2USEATEXT_RGBA)
					float4 staticSwitch159 = temp_output_371_0;
					#elif defined(_TEX2USEATEXT_A)
					float4 staticSwitch159 = temp_cast_4;
					#else
					float4 staticSwitch159 = temp_output_371_0;
					#endif
					float lerpResult354 = lerp( temp_output_237_0 , saturate( ( ( DissTex_R345 * _DissolveVaule ) + ( (0.0 + (temp_output_246_0 - 0.0) * (_DissolveMaxValue - 0.0) / (1.0 - 0.0)) * -2.0 ) + Const_1376 ) ) , _Diss_Mode);
					float lerpResult234 = lerp( (0) , lerpResult354 , _UseDissolve);
					float4 temp_output_88_0 = ( staticSwitch182 * staticSwitch159 * lerpResult234 * staticSwitch182 * i.color.a * _Alpha );
					float4 lerpResult315 = lerp( temp_output_88_0 , ( temp_output_88_0 * (0) ) , float4( 0,0,0,0 ));
					float4 appendResult87 = (float4(( (( _Usecenterglow )?( float3( 0,0,0 ) ):( (lerpResult231).rgb )) * lerpResult279 ) , lerpResult315.r));
					

					fixed4 col = appendResult87;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	
	
	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;179;-3564.244,-545.0338;Inherit;False;292.3999;254;CustomData;1;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-3514.244,-495.0338;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;152;-3434.734,-620.3987;Inherit;False;Property;_Tex1Offset_uv_Alpha_w1;UseCustomData:Tex1Offset(x,y);7;1;[Toggle];Create;False;1;;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-3407.02,-271.2985;Inherit;False;1037.896;533.6285;Textures movement;4;107;21;15;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;151;-3003.57,-658.9441;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;319;-3135.639,1556.56;Inherit;False;Property;_DissSpeedxy;DissSpeed(x,y);13;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;320;-2815.603,1512.262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2972.226,-227.1099;Inherit;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;321;-2837.215,1231.983;Inherit;False;0;188;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;322;-2593.186,1312.175;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;200;-2175.311,1177.17;Inherit;False;958.1622;616.0454;硬溶解;10;188;236;248;238;237;239;345;346;249;199;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2843.819,-106.5443;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-2604.489,-449.248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;107;-2647.623,-167.3645;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;188;-2051.94,1218.968;Inherit;True;Property;_DissolveTexture;DissolveTexture ;12;0;Create;True;0;0;0;False;0;False;-1;7b68906f9e7a833438271f46e5fb392a;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;194;-3075.463,2102.33;Inherit;False;Property;_DissolvePower;DissolvePower;14;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-3152.808,2256.522;Inherit;False;Property;_TexOffset_uv_Alpha_w2;UseCustomData:DissolvePower(z);15;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;215;-2777.533,2147.883;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-2192.52,1634.815;Inherit;False;Property;_Float3;硬邊溶解邊緣寬度;17;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-1513.269,36.91755;Inherit;False;Property;_MainScale;MainScale;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;249;-1920.237,1547.088;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.48;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;246;-2575.117,2159.772;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;248;-2170.314,1434.385;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;335;-2175.471,2030.843;Inherit;False;941.6393;550.989;軟溶解1;10;332;325;329;334;324;326;328;327;323;347;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;-1750.207,1547.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;236;-1572.805,1249.661;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;237;-1627.118,1472.271;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;362;-868.4637,998.3895;Inherit;False;877.2937;685.6398;硬邊溶解顏色;5;361;226;225;355;240;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-1112.651,-181.4539;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-1984.651,2172.959;Inherit;False;Property;_DissolveVaule;Soft_DissolveVaule;19;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;226;-818.4637,1475.029;Inherit;False;Property;_DissolveColor0;HardDissolveColor;18;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0.1231942,1;1,0,0.1231942,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;328;-1950.661,2277.49;Inherit;False;Constant;_Float2;Float 2;29;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;238;-1411.698,1498.636;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;329;-1870.78,2377.831;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-613.3978,1285.787;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-1619.428,2338.915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-1683.809,2124.378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;325;-1496.736,2167.125;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;225;-468.8333,1048.389;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-1326.224,1330.272;Inherit;False;Property;_Diss_Mode;Diss_Mode;16;1;[Enum];Create;True;0;2;Hard_Diss;0;Soft_Diss;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;326;-1398.632,2080.842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;355;-173.1699,1247.751;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;354;-1180.898,1127.986;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;-1299.497,932.9717;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;234;-1100.646,936.1569;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;78;-793.1474,-71.03638;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-437.423,534.0858;Inherit;False;Property;_Alpha;Alpha;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;393.2733,580.6287;Inherit;False;Constant;_Offset0;Offset0;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;392.5875,518.1387;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-3379.661,-722.5773;Inherit;False;374;Const_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;374;591.198,583.3284;Inherit;False;Const_0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;376;578.4705,488.4503;Inherit;False;Const_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-803.8221,1114.252;Inherit;False;360;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;345;-1773.031,1257.896;Inherit;False;DissTex_R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;-1856.785,1420.711;Inherit;False;345;DissTex_R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-1925.405,2079.885;Inherit;False;345;DissTex_R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-1700.877,2236.901;Inherit;False;376;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-3034.079,2177.36;Inherit;False;262;UV2_Z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-458.2499,216.0659;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-317.1401,456.0516;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-182.1854,321.7125;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;231;-968.5708,-34.05165;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1339.743,-144.9781;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-1601.77,993.0557;Inherit;False;Property;_UseDissolve;UseDissolve;11;2;[Header];[Toggle];Create;True;1;DissTex;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;32;-1759.748,598.8087;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;182;-1710.493,90.34238;Inherit;False;Property;_Tex1UseAtext;Tex1UseAtext;4;0;Create;True;0;0;0;False;1;Header(MainTex);False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;159;-1681.511,255.187;Inherit;False;Property;_Tex2UseAtext;Tex2UseAtext;8;0;Create;True;0;0;0;False;1;;False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;371;-1894.066,161.1174;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;367;-2030.897,124.7842;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;-1966.792,380.4938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;372;-1834.017,390.5275;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;15;-3393.739,-164.2956;Float;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-3250.977,-429.7518;Inherit;False;UV2_Z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;263;-3257.977,-359.7518;Inherit;False;UV2_W;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;113;-3241.325,-536.627;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-2231.518,314.3765;Inherit;False;Property;_Tex2Value;Tex2Value;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-2178.962,2487.98;Inherit;False;Property;_DissolveMaxValue;Soft_DissolveMaxValue;20;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;291;-1780.58,-468.8304;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-2294.135,-206.7004;Inherit;True;Property;_Main;Main;5;0;Create;True;1;;0;0;False;0;False;-1;548ceef3d1bffcc4fb33e364369f7fb8;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;292;-1554.047,-448.1034;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-1699.076,-287.1118;Inherit;False;Property;_MainTex_Color;MainTex_Color;6;1;[Enum];Create;True;0;2;GrayScale;0;Color_RGBA;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;256;-1642.476,-178.9776;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;-1873.903,-109.0476;Inherit;False;376;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;826.3364,3.431657;Float;False;True;-1;2;;0;11;VFX/Blend3_CenterGlow2;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;2;True;_CullMode;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;False;True;True;1;True;_Zwrite;True;3;False;;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;532.628,3.364667;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;315;297.4983,142.2587;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;278.1854,-72.30505;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;279;-143.3833,-118.4639;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-335.2474,-204.6021;Float;False;Property;_Emission;Emission;0;1;[Header];Create;True;1;ColorGradient;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-474.7641,17.79279;Inherit;False;Property;_UseCustomDataEmissionw;UseCustomData:Emission(w);1;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-426.232,-75.68095;Inherit;False;263;UV2_W;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;90;-233.8772,-369.6431;Float;False;Property;_Usecenterglow;Use center glow?;21;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;151;0;273;0
WireConnection;151;1;113;0
WireConnection;151;2;152;0
WireConnection;320;0;319;1
WireConnection;320;1;319;2
WireConnection;322;0;321;0
WireConnection;322;2;320;0
WireConnection;21;0;15;1
WireConnection;21;1;15;2
WireConnection;115;0;151;0
WireConnection;115;1;29;0
WireConnection;107;0;115;0
WireConnection;107;2;21;0
WireConnection;188;1;322;0
WireConnection;215;0;194;0
WireConnection;215;1;265;0
WireConnection;215;2;217;0
WireConnection;249;0;199;0
WireConnection;246;0;215;0
WireConnection;248;0;246;0
WireConnection;239;0;346;0
WireConnection;239;1;249;0
WireConnection;236;0;248;0
WireConnection;236;1;345;0
WireConnection;237;0;248;0
WireConnection;237;1;239;0
WireConnection;360;0;30;0
WireConnection;238;0;237;0
WireConnection;238;1;236;0
WireConnection;329;0;246;0
WireConnection;329;4;332;0
WireConnection;240;0;361;0
WireConnection;240;1;238;0
WireConnection;240;2;226;0
WireConnection;327;0;329;0
WireConnection;327;1;328;0
WireConnection;323;0;347;0
WireConnection;323;1;324;0
WireConnection;325;0;323;0
WireConnection;325;1;327;0
WireConnection;325;2;334;0
WireConnection;225;0;361;0
WireConnection;225;1;240;0
WireConnection;225;2;238;0
WireConnection;326;0;325;0
WireConnection;355;0;225;0
WireConnection;355;1;361;0
WireConnection;355;2;353;0
WireConnection;354;0;237;0
WireConnection;354;1;326;0
WireConnection;354;2;353;0
WireConnection;234;0;288;0
WireConnection;234;1;354;0
WireConnection;234;2;233;0
WireConnection;78;0;231;0
WireConnection;374;0;373;0
WireConnection;376;0;375;0
WireConnection;345;0;188;1
WireConnection;88;0;182;0
WireConnection;88;1;159;0
WireConnection;88;2;234;0
WireConnection;88;3;182;0
WireConnection;88;4;32;4
WireConnection;88;5;255;0
WireConnection;312;0;88;0
WireConnection;312;1;318;0
WireConnection;231;0;360;0
WireConnection;231;1;355;0
WireConnection;231;2;233;0
WireConnection;30;0;292;0
WireConnection;30;1;256;0
WireConnection;30;2;32;0
WireConnection;30;3;251;0
WireConnection;182;1;13;0
WireConnection;182;0;13;4
WireConnection;159;1;371;0
WireConnection;159;0;372;0
WireConnection;371;0;367;0
WireConnection;367;0;13;0
WireConnection;367;1;368;0
WireConnection;369;1;368;0
WireConnection;372;0;369;0
WireConnection;262;0;111;3
WireConnection;263;0;111;4
WireConnection;113;0;111;1
WireConnection;113;1;111;2
WireConnection;13;1;107;0
WireConnection;292;0;291;0
WireConnection;292;1;13;0
WireConnection;292;2;296;0
WireConnection;256;0;13;0
WireConnection;256;1;377;0
WireConnection;256;2;371;0
WireConnection;68;0;87;0
WireConnection;87;0;51;0
WireConnection;87;3;315;0
WireConnection;315;0;88;0
WireConnection;315;1;312;0
WireConnection;51;0;90;0
WireConnection;51;1;279;0
WireConnection;279;0;52;0
WireConnection;279;1;264;0
WireConnection;279;2;281;0
WireConnection;90;0;78;0
ASEEND*/
//CHKSM=D1AF59547DEBB7B66C9E5656F670C0D9577AD731