// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/Add_CenterGlow"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[Header(ColorGradient)]_Emission("Emission", Float) = 2
		_MainScale("MainScale", Float) = 1
		[HDR]_Color1("Color1", Color) = (1,1,1,1)
		[HDR]_Color2("Color2", Color) = (1,0,0,1)
		[Toggle]_Float0("使用漸層(Color2)?", Float) = 0
		[KeywordEnum(Polar,Horizontal,Vertical)] _Gradient("Gradient", Float) = 0
		_ColorGradient("Size_Melt_漸層偏移(x,y)", Vector) = (1,1,0,0)
		[Header(MainTex)][KeywordEnum(RGBA,A)] _Tex1UseAtext("Tex1UseAtext", Float) = 0
		_Main("Main", 2D) = "white" {}
		[Toggle]_Tex1Offsetxy("UseCustomData:Tex1Offset(x,y)", Float) = 0
		[KeywordEnum(RGBA,A)] _Tex2UseAtext("Tex2UseAtext", Float) = 0
		[HDR]_Color3("Color3", Color) = (1,0,0,1)
		_Tex2("Tex2", 2D) = "white" {}
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		[Header(NoiseTex)][Toggle]_UseFlow("UseFlow", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseMask("NoiseMask", 2D) = "white" {}
		_DistortionSpeedXYPowerZ("Distortion Speed XY Power Z", Vector) = (0,0,0,0)
		[Toggle]_UseDissolve("UseDissolve", Float) = 0
		_DissolveTexture("DissolveTexture ", 2D) = "white" {}
		_DissolvePower("DissolvePower", Range( 0 , 1)) = 0.7103257
		_Float3("溶解邊緣寬度", Range( 0 , 1)) = 0.5099
		[HDR]_DissolveColor("DissolveColor", Color) = (1,0,0,1)
		_DissSpeedxy("DissSpeed(x,y)無zw", Vector) = (0,0,0,0)
		[Toggle]_TexOffset_uv_Alpha_w2("UseCustomData:Dissolve(z)", Float) = 0
		[Toggle]_NoisePowerz("UseCustomData:DissolveWidge(w)", Float) = 0
		[Toggle]_Usecenterglow("Use center glow?", Float) = 0
		[Toggle]_Zwrite("Zwrite", Float) = 0
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend One One
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
				#pragma shader_feature_local _GRADIENT_POLAR _GRADIENT_HORIZONTAL _GRADIENT_VERTICAL


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
				uniform float _CullMode;
				uniform float _Zwrite;
				uniform float _Usecenterglow;
				uniform sampler2D _Main;
				uniform float4 _SpeedMainTexUVNoiseZW;
				uniform float _Tex1Offsetxy;
				uniform float4 _Main_ST;
				uniform sampler2D _Noise;
				uniform float4 _DistortionSpeedXYPowerZ;
				uniform float4 _Noise_ST;
				uniform sampler2D _NoiseMask;
				uniform float4 _NoiseMask_ST;
				uniform float _UseFlow;
				uniform float4 _Color3;
				uniform sampler2D _Tex2;
				uniform float4 _Tex2_ST;
				uniform float4 _Color1;
				uniform float4 _Color2;
				uniform float4 _ColorGradient;
				uniform float _Float0;
				uniform float _DissolvePower;
				uniform float _TexOffset_uv_Alpha_w2;
				uniform sampler2D _DissolveTexture;
				uniform float4 _DissSpeedxy;
				uniform float4 _DissolveTexture_ST;
				uniform float _Float3;
				uniform float _NoisePowerz;
				uniform float _UseDissolve;
				uniform float _MainScale;
				uniform float4 _DissolveColor;
				uniform float _Emission;


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

					float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
					float2 temp_cast_0 = (0.0).xx;
					float4 texCoord132 = i.ase_texcoord3;
					texCoord132.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult135 = (float2(texCoord132.x , texCoord132.y));
					float2 lerpResult136 = lerp( temp_cast_0 , appendResult135 , _Tex1Offsetxy);
					float2 uv_Main = i.texcoord.xy * _Main_ST.xy + _Main_ST.zw;
					float2 panner107 = ( 1.0 * _Time.y * appendResult21 + ( lerpResult136 + uv_Main ));
					float2 temp_cast_1 = (0.0).xx;
					float2 appendResult100 = (float2(_DistortionSpeedXYPowerZ.x , _DistortionSpeedXYPowerZ.y));
					float3 uvs3_Noise = i.texcoord.xyz;
					uvs3_Noise.xy = i.texcoord.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
					float2 panner110 = ( 1.0 * _Time.y * appendResult100 + (uvs3_Noise).xy);
					float2 uv_NoiseMask = i.texcoord.xy * _NoiseMask_ST.xy + _NoiseMask_ST.zw;
					float4 tex2DNode33 = tex2D( _NoiseMask, uv_NoiseMask );
					float Flowpower102 = _DistortionSpeedXYPowerZ.z;
					float2 lerpResult170 = lerp( temp_cast_1 , ( (( tex2D( _Noise, panner110 ) * tex2DNode33 )).rg * Flowpower102 ) , _UseFlow);
					float4 tex2DNode13 = tex2D( _Main, ( panner107 - lerpResult170 ) );
					float4 temp_cast_2 = (tex2DNode13.a).xxxx;
					#if defined(_TEX1USEATEXT_RGBA)
					float4 staticSwitch166 = tex2DNode13;
					#elif defined(_TEX1USEATEXT_A)
					float4 staticSwitch166 = temp_cast_2;
					#else
					float4 staticSwitch166 = tex2DNode13;
					#endif
					float4 temp_cast_3 = (1.0).xxxx;
					float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
					float2 uv_Tex2 = i.texcoord.xy * _Tex2_ST.xy + _Tex2_ST.zw;
					float2 panner108 = ( 1.0 * _Time.y * appendResult22 + uv_Tex2);
					float4 tex2DNode14 = tex2D( _Tex2, panner108 );
					float4 lerpResult195 = lerp( _Color3 , temp_cast_3 , tex2DNode14);
					float4 temp_cast_4 = (tex2DNode14.a).xxxx;
					#if defined(_TEX2USEATEXT_RGBA)
					float4 staticSwitch168 = lerpResult195;
					#elif defined(_TEX2USEATEXT_A)
					float4 staticSwitch168 = temp_cast_4;
					#else
					float4 staticSwitch168 = lerpResult195;
					#endif
					float2 appendResult117 = (float2(_ColorGradient.z , _ColorGradient.w));
					float2 texCoord118 = i.texcoord.xy * float2( 1,1 ) + appendResult117;
					float2 temp_cast_5 = (texCoord118.x).xx;
					float2 temp_cast_6 = (texCoord118.y).xx;
					#if defined(_GRADIENT_POLAR)
					float2 staticSwitch119 = texCoord118;
					#elif defined(_GRADIENT_HORIZONTAL)
					float2 staticSwitch119 = temp_cast_5;
					#elif defined(_GRADIENT_VERTICAL)
					float2 staticSwitch119 = temp_cast_6;
					#else
					float2 staticSwitch119 = texCoord118;
					#endif
					float clampResult9_g1 = clamp( ( ( length( (float2( -1,-1 ) + (staticSwitch119 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) ) + -_ColorGradient.x ) * _ColorGradient.y ) , 0.0 , 1.0 );
					float4 lerpResult126 = lerp( _Color2 , _Color1 , clampResult9_g1);
					float4 lerpResult127 = lerp( _Color1 , lerpResult126 , _Float0);
					float lerpResult144 = lerp( _DissolvePower , texCoord132.z , _TexOffset_uv_Alpha_w2);
					float temp_output_190_0 = (0.0 + (( 1.0 - lerpResult144 ) - 0.0) * (1.5 - 0.0) / (1.0 - 0.0));
					float2 appendResult198 = (float2(_DissSpeedxy.x , _DissSpeedxy.y));
					float2 uv_DissolveTexture = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float2 panner199 = ( 1.0 * _Time.y * appendResult198 + uv_DissolveTexture);
					float4 tex2DNode147 = tex2D( _DissolveTexture, ( lerpResult170 + panner199 ) );
					float lerpResult172 = lerp( _Float3 , texCoord132.w , _NoisePowerz);
					float temp_output_182_0 = step( temp_output_190_0 , ( tex2DNode147.r + (0.0 + (lerpResult172 - 0.0) * (0.48 - 0.0) / (1.0 - 0.0)) ) );
					float lerpResult189 = lerp( 1.0 , temp_output_182_0 , _UseDissolve);
					float4 temp_output_30_0 = ( staticSwitch166 * staticSwitch168 * lerpResult127 * i.color * tex2DNode13.a * tex2DNode14.a * (lerpResult126).a * i.color.a * lerpResult189 * _MainScale );
					float temp_output_184_0 = ( temp_output_182_0 - step( temp_output_190_0 , tex2DNode147.r ) );
					float4 lerpResult185 = lerp( temp_output_30_0 , ( temp_output_184_0 * _DissolveColor * temp_output_30_0 ) , temp_output_184_0);
					float4 lerpResult186 = lerp( temp_output_30_0 , lerpResult185 , _UseDissolve);
					float4 temp_output_188_0 = (lerpResult186).rgba;
					float4 temp_cast_7 = ((1.0 + (uvs3_Noise.z - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))).xxxx;
					float4 clampResult38 = clamp( ( tex2DNode33 - temp_cast_7 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float4 clampResult40 = clamp( ( tex2DNode33 * clampResult38 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					

					fixed4 col = ( (( _Usecenterglow )?( ( temp_output_188_0 * clampResult40 ) ):( temp_output_188_0 )) * _Emission );
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	
	
	
}
/*ASEBEGIN
Version=18935
-1281.6;58.4;1099;763;3647.518;-1188.318;1.380064;True;False
Node;AmplifyShaderEditor.CommentaryNode;104;-4130.993,490.5418;Inherit;False;1910.996;537.6462;Texture distortion;13;91;33;100;102;99;94;95;103;92;59;98;110;169;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;99;-3968.293,619.481;Float;False;Property;_DistortionSpeedXYPowerZ;Distortion Speed XY Power Z;17;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;98;-3920.299,848.9976;Inherit;False;0;91;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;100;-3535.482,654.5021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;59;-3583.603,566.496;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;110;-3339.196,596.5295;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-3146.373,763.0061;Inherit;True;Property;_NoiseMask;NoiseMask;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;91;-3152.937,567.9764;Inherit;True;Property;_Noise;Noise;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;116;-1969.176,-1501.665;Inherit;False;Property;_ColorGradient;Size_Melt_漸層偏移(x,y);6;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2762.212,550.0183;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-3556.945,748.0421;Float;False;Flowpower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;131;-3812.284,-602.5402;Inherit;False;292.3999;254;CustomData;1;132;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;132;-3762.284,-552.5402;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;117;-1583.215,-1462.044;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;-2609.926,543.6367;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2605.07,630.9626;Inherit;False;102;Flowpower;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;197;-3111.039,1690.379;Inherit;False;Property;_DissSpeedxy;DissSpeed(x,y)無zw;23;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;198;-2857.245,1758.67;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;139;-2919.254,1548.866;Inherit;False;0;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;-2249.951,378.9705;Inherit;False;Constant;_Offset0;Offset0;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-3489.008,-875.4456;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-1326.872,-1510.825;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;109;-3401.27,-330.4436;Inherit;False;1037.896;533.6285;Textures movement;7;107;108;29;21;89;22;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-3484.544,-630.3297;Inherit;False;Property;_Tex1Offsetxy;UseCustomData:Tex1Offset(x,y);9;1;[Toggle];Create;False;1;;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-2388.997,542.6455;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2347.835,722.2481;Inherit;False;Property;_UseFlow;UseFlow;14;2;[Header];[Toggle];Create;True;1;NoiseTex;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;199;-2604.404,1693.316;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;170;-2093.417,510.9942;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;119;-1059.695,-1513.324;Inherit;False;Property;_Gradient;Gradient;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Polar;Horizontal;Vertical;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-3026.788,-269.4436;Inherit;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;171;-2936.945,2282.822;Inherit;False;Property;_NoisePowerz;UseCustomData:DissolveWidge(w);25;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;15;-3351.27,-101.4007;Float;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;138;-2298.52,1629.623;Inherit;False;958.1622;616.0454;溶解;6;147;144;142;183;190;192;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-3110.433,2167.645;Inherit;False;Property;_Float3;溶解邊緣寬度;21;0;Create;False;0;0;0;False;0;False;0.5099;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-2760.484,2083.881;Inherit;False;Property;_TexOffset_uv_Alpha_w2;UseCustomData:Dissolve(z);24;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-3049.096,1943.918;Inherit;False;Property;_DissolvePower;DissolvePower;20;0;Create;True;0;0;0;False;0;False;0.7103257;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;-3213.285,-807.6373;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2778.501,-153.1786;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;172;-2460.439,2126.771;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;144;-2342.952,1932.012;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-2326.873,1674.718;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-2852.529,-506.7543;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;-2861.858,-55.04038;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;120;-815.9835,-1361.937;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2766.722,70.18491;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;147;-2188.851,1650.572;Inherit;True;Property;_DissolveTexture;DissolveTexture ;19;0;Create;True;0;0;0;False;0;False;-1;None;3f1d4fadb37c37e4488860109d7dce4b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;192;-2182.801,1868.526;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;108;-2577.237,-21.63752;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;191;-2177.962,2226.498;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.48;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;121;-1286.096,-1325.88;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;107;-2570.374,-239.5098;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;124;-1739.754,-1123.085;Float;False;Property;_Color2;Color2;3;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;123;-1743.642,-848.2756;Float;False;Property;_Color1;Color1;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;190;-1944.758,1896.356;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1919.39,107.4101;Inherit;True;Property;_Tex2;Tex2;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;122;-1222.581,-1243.222;Inherit;True;RadialGradient;-1;;1;ec972f7745a8353409da2eb8d000a2e3;0;3;1;FLOAT2;0,0;False;6;FLOAT;1.02;False;7;FLOAT;1.97;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-1989.684,-41.77601;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1813.871,570.8754;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;196;-1844.025,316.9889;Float;False;Property;_Color3;Color3;11;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-1778.731,2334.61;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-1790.179,-110.7617;Inherit;True;Property;_Main;Main;8;0;Create;True;1;;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;126;-1296.914,-902.9822;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;182;-1615.479,2281.52;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;195;-1580.126,295.8987;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1615.796,-509.9395;Inherit;False;Property;_Float0;使用漸層(Color2)?;4;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1502.452,1319.249;Inherit;False;Property;_UseDissolve;UseDissolve;18;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;168;-1401.221,190.7686;Inherit;False;Property;_Tex2UseAtext;Tex2UseAtext;10;0;Create;True;0;0;0;False;1;;False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;32;-1670.612,486.0577;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;166;-1463.772,-42.60713;Inherit;False;Property;_Tex1UseAtext;Tex1UseAtext;7;0;Create;True;0;0;0;False;1;Header(MainTex);False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-1351.012,503.2687;Inherit;False;Property;_MainScale;MainScale;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;128;-1014.266,-256.7161;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;183;-1601.119,1929.797;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;-1356.433,-427.5521;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;189;-1325.805,1419.467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;36;-2593.01,1192.018;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1187.357,127.2037;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;184;-1301.564,2154.344;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;153;-1254.132,2388.814;Inherit;False;Property;_DissolveColor;DissolveColor;22;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-966.1964,1863.762;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;-2323.357,1205.497;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;38;-2155.728,1213.684;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;185;-812.0452,1286.282;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1937.593,1156.593;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;186;-602.7635,747.3151;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;40;-1764.275,1143.857;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;188;-715.1143,127.9955;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-497.0516,207.9021;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;90;-213.4547,109.3846;Float;False;Property;_Usecenterglow;Use center glow?;26;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-138.0177,210.4267;Float;False;Property;_Emission;Emission;0;1;[Header];Create;True;1;ColorGradient;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;22.23254,113.1316;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;193;-2368.408,1823.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1702.053,-371.8433;Inherit;False;Property;_Zwrite;Zwrite;27;1;[Toggle];Create;True;0;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1809.825,-478.0839;Inherit;False;Property;_CullMode;CullMode;28;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;72;-1580.242,1135.946;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;161.1757,115.9263;Float;False;True;-1;2;;0;7;VFX/Add_CenterGlow;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;2;True;129;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;True;True;2;True;130;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;100;0;99;1
WireConnection;100;1;99;2
WireConnection;59;0;98;0
WireConnection;110;0;59;0
WireConnection;110;2;100;0
WireConnection;91;1;110;0
WireConnection;92;0;91;0
WireConnection;92;1;33;0
WireConnection;102;0;99;3
WireConnection;117;0;116;3
WireConnection;117;1;116;4
WireConnection;94;0;92;0
WireConnection;198;0;197;1
WireConnection;198;1;197;2
WireConnection;135;0;132;1
WireConnection;135;1;132;2
WireConnection;118;1;117;0
WireConnection;95;0;94;0
WireConnection;95;1;103;0
WireConnection;199;0;139;0
WireConnection;199;2;198;0
WireConnection;170;0;134;0
WireConnection;170;1;95;0
WireConnection;170;2;169;0
WireConnection;119;1;118;0
WireConnection;119;0;118;1
WireConnection;119;2;118;2
WireConnection;136;0;134;0
WireConnection;136;1;135;0
WireConnection;136;2;133;0
WireConnection;21;0;15;1
WireConnection;21;1;15;2
WireConnection;172;0;149;0
WireConnection;172;1;132;4
WireConnection;172;2;171;0
WireConnection;144;0;140;0
WireConnection;144;1;132;3
WireConnection;144;2;141;0
WireConnection;142;0;170;0
WireConnection;142;1;199;0
WireConnection;137;0;136;0
WireConnection;137;1;29;0
WireConnection;120;0;119;0
WireConnection;22;0;15;3
WireConnection;22;1;15;4
WireConnection;147;1;142;0
WireConnection;192;0;144;0
WireConnection;108;0;89;0
WireConnection;108;2;22;0
WireConnection;191;0;172;0
WireConnection;121;0;120;0
WireConnection;107;0;137;0
WireConnection;107;2;21;0
WireConnection;190;0;192;0
WireConnection;14;1;108;0
WireConnection;122;1;121;0
WireConnection;122;6;116;1
WireConnection;122;7;116;2
WireConnection;96;0;107;0
WireConnection;96;1;170;0
WireConnection;181;0;147;1
WireConnection;181;1;191;0
WireConnection;13;1;96;0
WireConnection;126;0;124;0
WireConnection;126;1;123;0
WireConnection;126;2;122;0
WireConnection;182;0;190;0
WireConnection;182;1;181;0
WireConnection;195;0;196;0
WireConnection;195;1;145;0
WireConnection;195;2;14;0
WireConnection;168;1;195;0
WireConnection;168;0;14;4
WireConnection;166;1;13;0
WireConnection;166;0;13;4
WireConnection;128;0;126;0
WireConnection;183;0;190;0
WireConnection;183;1;147;1
WireConnection;127;0;123;0
WireConnection;127;1;126;0
WireConnection;127;2;125;0
WireConnection;189;0;145;0
WireConnection;189;1;182;0
WireConnection;189;2;187;0
WireConnection;36;0;98;3
WireConnection;30;0;166;0
WireConnection;30;1;168;0
WireConnection;30;2;127;0
WireConnection;30;3;32;0
WireConnection;30;4;13;4
WireConnection;30;5;14;4
WireConnection;30;6;128;0
WireConnection;30;7;32;4
WireConnection;30;8;189;0
WireConnection;30;9;194;0
WireConnection;184;0;182;0
WireConnection;184;1;183;0
WireConnection;154;0;184;0
WireConnection;154;1;153;0
WireConnection;154;2;30;0
WireConnection;37;0;33;0
WireConnection;37;1;36;0
WireConnection;38;0;37;0
WireConnection;185;0;30;0
WireConnection;185;1;154;0
WireConnection;185;2;184;0
WireConnection;39;0;33;0
WireConnection;39;1;38;0
WireConnection;186;0;30;0
WireConnection;186;1;185;0
WireConnection;186;2;187;0
WireConnection;40;0;39;0
WireConnection;188;0;186;0
WireConnection;41;0;188;0
WireConnection;41;1;40;0
WireConnection;90;0;188;0
WireConnection;90;1;41;0
WireConnection;51;0;90;0
WireConnection;51;1;52;0
WireConnection;72;0;40;0
WireConnection;68;0;51;0
ASEEND*/
//CHKSM=6B9279ABA0E124635D81A2DCB128062841DCAC28