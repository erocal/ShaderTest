// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/Blend3_CenterGlow"
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
		[HDR]_Color1("Color1", Color) = (1,1,1,1)
		[HDR]_Color2("Color2", Color) = (1,0,0,1)
		[Toggle]_Float0("使用漸層(Color2)?", Float) = 0
		[KeywordEnum(Polar,Horizontal,Vertical)] _Gradient("GradientMode", Float) = 0
		_ColorGradient("Size_Melt_漸層偏移(x,y)", Vector) = (1,1,0,0)
		[Header(MainTex)][KeywordEnum(RGBA,A)] _Tex1UseAtext("Tex1UseAtext", Float) = 0
		_Main("Main", 2D) = "white" {}
		[Enum(GrayScale,0,Color_RGBA,1)]_MainTex_Color("MainTex_Color", Float) = 1
		[Toggle]_Tex1Offset_uv_Alpha_w1("UseCustomData:Tex1Offset(x,y)", Float) = 0
		[KeywordEnum(RGBA,A)] _Tex2UseAtext("Tex2UseAtext", Float) = 0
		[HDR]_Color3("Color3_(不要寫入Tex2顏色時,此欄調整成白色)", Color) = (0,0,0,1)
		_Tex2("Tex2", 2D) = "white" {}
		_Tex2Value("Tex2Value", Float) = 1
		[Toggle]_CustomDataTex1_2Offset("讓CustomData一起控Tex1與2Offset", Float) = 0
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		[Header(NoiseTex)][Toggle]_UseFlow("UseNoise", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseMask("NoiseMask", 2D) = "white" {}
		_DistortionSpeedXYPowerZ("Distortion Speed XY Power Z", Vector) = (0,0,0,0)
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
		[Header(Vertex)][Toggle]_UseVertexMove("UseVertexMove", Float) = 0
		_VertexTexture("VertexTexture", 2D) = "white" {}
		_VertexSpeedXY("Vertex Speed XY PowerZ", Vector) = (0,0,0,0)
		[Header(Mask)][Toggle]_UseMask("UseMask", Float) = 0
		_MaskTexture("MaskTexture", 2D) = "white" {}
		_MaskPower("MaskPower", Float) = 1
		_MaskSpeedXY("MaskSpeed XY_無zw", Vector) = (0,0,0,0)
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
				#pragma shader_feature_local _GRADIENT_POLAR _GRADIENT_HORIZONTAL _GRADIENT_VERTICAL
				#pragma shader_feature_local _TEX1USEATEXT_RGBA _TEX1USEATEXT_A
				#pragma shader_feature_local _TEX2USEATEXT_RGBA _TEX2USEATEXT_A


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					float4 ase_tangent : TANGENT;
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
				uniform float _Zwrite;
				uniform float _CullMode;
				uniform sampler2D _VertexTexture;
				uniform float4 _VertexSpeedXY;
				uniform float4 _VertexTexture_ST;
				uniform float _UseVertexMove;
				uniform float _Usecenterglow;
				uniform sampler2D _Main;
				uniform float4 _SpeedMainTexUVNoiseZW;
				uniform float _Tex1Offset_uv_Alpha_w1;
				uniform float4 _Main_ST;
				uniform sampler2D _Noise;
				uniform float4 _DistortionSpeedXYPowerZ;
				uniform float4 _Noise_ST;
				uniform sampler2D _NoiseMask;
				uniform float4 _NoiseMask_ST;
				uniform float _UseFlow;
				uniform float _MainTex_Color;
				uniform float4 _Color3;
				uniform sampler2D _Tex2;
				uniform float4 _Tex2_ST;
				uniform float _CustomDataTex1_2Offset;
				uniform float _Tex2Value;
				uniform float4 _Color1;
				uniform float4 _Color2;
				uniform float4 _ColorGradient;
				uniform float _Float0;
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
				uniform sampler2D _MaskTexture;
				uniform float4 _MaskSpeedXY;
				uniform float4 _MaskTexture_ST;
				uniform float _MaskPower;
				uniform float _UseMask;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					float Const_0274 = 0.0;
					float4 temp_cast_0 = (Const_0274).xxxx;
					float2 appendResult271 = (float2(_VertexSpeedXY.x , _VertexSpeedXY.y));
					float2 uv_VertexTexture = v.texcoord.xy * _VertexTexture_ST.xy + _VertexTexture_ST.zw;
					float2 panner267 = ( 1.0 * _Time.y * appendResult271 + uv_VertexTexture);
					float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
					float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
					float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
					float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
					float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
					float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
					float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
					float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
					ase_worldViewDir = normalize(ase_worldViewDir);
					float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
					ase_tanViewDir = normalize(ase_tanViewDir);
					float4 lerpResult272 = lerp( temp_cast_0 , ( tex2Dlod( _VertexTexture, float4( panner267, 0, 0.0) ) * _VertexSpeedXY.z * float4( ase_tanViewDir , 0.0 ) ) , _UseVertexMove);
					
					o.ase_texcoord3 = v.ase_texcoord1;

					v.vertex.xyz += lerpResult272.rgb;
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

					float Const_1287 = 1.0;
					float4 temp_cast_0 = (Const_1287).xxxx;
					float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
					float Const_0274 = 0.0;
					float2 temp_cast_1 = (Const_0274).xx;
					float4 texCoord111 = i.ase_texcoord3;
					texCoord111.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult113 = (float2(texCoord111.x , texCoord111.y));
					float2 lerpResult151 = lerp( temp_cast_1 , appendResult113 , _Tex1Offset_uv_Alpha_w1);
					float2 uv_Main = i.texcoord.xy * _Main_ST.xy + _Main_ST.zw;
					float2 panner107 = ( 1.0 * _Time.y * appendResult21 + ( lerpResult151 + uv_Main ));
					float2 temp_cast_2 = (Const_0274).xx;
					float2 appendResult100 = (float2(_DistortionSpeedXYPowerZ.x , _DistortionSpeedXYPowerZ.y));
					float3 uvs3_Noise = i.texcoord.xyz;
					uvs3_Noise.xy = i.texcoord.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
					float2 panner110 = ( 1.0 * _Time.y * appendResult100 + (uvs3_Noise).xy);
					float2 uv_NoiseMask = i.texcoord.xy * _NoiseMask_ST.xy + _NoiseMask_ST.zw;
					float4 tex2DNode33 = tex2D( _NoiseMask, uv_NoiseMask );
					float Flowpower102 = _DistortionSpeedXYPowerZ.z;
					float2 lerpResult222 = lerp( temp_cast_2 , ( (( tex2D( _Noise, panner110 ) * tex2DNode33 )).rg * Flowpower102 ) , _UseFlow);
					float4 tex2DNode13 = tex2D( _Main, ( panner107 - lerpResult222 ) );
					float4 lerpResult292 = lerp( temp_cast_0 , tex2DNode13 , _MainTex_Color);
					float4 temp_cast_3 = (Const_1287).xxxx;
					float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
					float2 uv_Tex2 = i.texcoord.xy * _Tex2_ST.xy + _Tex2_ST.zw;
					float2 lerpResult365 = lerp( uv_Tex2 , ( lerpResult151 + uv_Tex2 ) , _CustomDataTex1_2Offset);
					float2 panner108 = ( 1.0 * _Time.y * appendResult22 + lerpResult365);
					float4 tex2DNode14 = tex2D( _Tex2, panner108 );
					float4 temp_output_371_0 = saturate( ( tex2DNode14 * _Tex2Value ) );
					float4 lerpResult256 = lerp( _Color3 , temp_cast_3 , temp_output_371_0);
					float2 appendResult147 = (float2(_ColorGradient.z , _ColorGradient.w));
					float2 texCoord142 = i.texcoord.xy * float2( 1,1 ) + appendResult147;
					float2 temp_cast_4 = (texCoord142.x).xx;
					float2 temp_cast_5 = (texCoord142.y).xx;
					#if defined(_GRADIENT_POLAR)
					float2 staticSwitch149 = texCoord142;
					#elif defined(_GRADIENT_HORIZONTAL)
					float2 staticSwitch149 = temp_cast_4;
					#elif defined(_GRADIENT_VERTICAL)
					float2 staticSwitch149 = temp_cast_5;
					#else
					float2 staticSwitch149 = texCoord142;
					#endif
					float clampResult9_g1 = clamp( ( ( length( (float2( -1,-1 ) + (staticSwitch149 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) ) + -_ColorGradient.x ) * _ColorGradient.y ) , 0.0 , 1.0 );
					float4 lerpResult119 = lerp( _Color2 , _Color1 , clampResult9_g1);
					float4 lerpResult180 = lerp( _Color1 , lerpResult119 , _Float0);
					float4 MainTex360 = ( lerpResult292 * lerpResult256 * lerpResult180 * i.color * _MainScale );
					float UV2_Z262 = texCoord111.z;
					float lerpResult215 = lerp( _DissolvePower , UV2_Z262 , _TexOffset_uv_Alpha_w2);
					float temp_output_246_0 = ( 1.0 - lerpResult215 );
					float temp_output_248_0 = (0.0 + (temp_output_246_0 - 0.0) * (1.5 - 0.0) / (1.0 - 0.0));
					float2 appendResult320 = (float2(_DissSpeedxy.x , _DissSpeedxy.y));
					float2 uv_DissolveTexture = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float2 panner322 = ( 1.0 * _Time.y * appendResult320 + uv_DissolveTexture);
					float DissTex_R345 = tex2D( _DissolveTexture, ( lerpResult222 + panner322 ) ).r;
					float temp_output_237_0 = step( temp_output_248_0 , ( DissTex_R345 + (0.0 + (_Float3 - 0.0) * (0.48 - 0.0) / (1.0 - 0.0)) ) );
					float temp_output_238_0 = ( temp_output_237_0 - step( temp_output_248_0 , DissTex_R345 ) );
					float4 lerpResult225 = lerp( MainTex360 , ( MainTex360 * temp_output_238_0 * _DissolveColor0 ) , temp_output_238_0);
					float4 lerpResult355 = lerp( lerpResult225 , MainTex360 , _Diss_Mode);
					float4 lerpResult231 = lerp( MainTex360 , lerpResult355 , _UseDissolve);
					float3 temp_output_78_0 = (lerpResult231).rgb;
					float4 temp_cast_6 = ((1.0 + (uvs3_Noise.z - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))).xxxx;
					float4 clampResult40 = clamp( ( tex2DNode33 * ( tex2DNode33 - temp_cast_6 ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float UV2_W263 = texCoord111.w;
					float lerpResult279 = lerp( _Emission , UV2_W263 , _UseCustomDataEmissionw);
					float4 temp_cast_7 = (tex2DNode13.a).xxxx;
					#if defined(_TEX1USEATEXT_RGBA)
					float4 staticSwitch182 = tex2DNode13;
					#elif defined(_TEX1USEATEXT_A)
					float4 staticSwitch182 = temp_cast_7;
					#else
					float4 staticSwitch182 = tex2DNode13;
					#endif
					float4 temp_cast_8 = (saturate( ( tex2DNode14.a * _Tex2Value ) )).xxxx;
					#if defined(_TEX2USEATEXT_RGBA)
					float4 staticSwitch159 = temp_output_371_0;
					#elif defined(_TEX2USEATEXT_A)
					float4 staticSwitch159 = temp_cast_8;
					#else
					float4 staticSwitch159 = temp_output_371_0;
					#endif
					float lerpResult354 = lerp( temp_output_237_0 , saturate( ( ( DissTex_R345 * _DissolveVaule ) + ( (0.0 + (temp_output_246_0 - 0.0) * (_DissolveMaxValue - 0.0) / (1.0 - 0.0)) * -2.0 ) + Const_1287 ) ) , _Diss_Mode);
					float lerpResult234 = lerp( Const_1287 , lerpResult354 , _UseDissolve);
					float4 temp_output_88_0 = ( staticSwitch182 * staticSwitch159 * lerpResult234 * (lerpResult119).a * i.color.a * _Alpha );
					float2 appendResult300 = (float2(_MaskSpeedXY.x , _MaskSpeedXY.y));
					float2 uv_MaskTexture = i.texcoord.xy * _MaskTexture_ST.xy + _MaskTexture_ST.zw;
					float2 panner301 = ( 1.0 * _Time.y * appendResult300 + uv_MaskTexture);
					float Mask317 = saturate( ( tex2D( _MaskTexture, panner301 ).r * _MaskPower ) );
					float4 lerpResult315 = lerp( temp_output_88_0 , ( temp_output_88_0 * Mask317 ) , _UseMask);
					float4 appendResult87 = (float4(( (( _Usecenterglow )?( ( temp_output_78_0 * (clampResult40).rgb ) ):( temp_output_78_0 )) * lerpResult279 ) , lerpResult315.r));
					

					fixed4 col = appendResult87;
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
-1394.4;59.2;1296;655;4800.455;1153.185;3.936452;True;False
Node;AmplifyShaderEditor.CommentaryNode;104;-4103.653,490.5418;Inherit;False;1910.996;537.6462;Texture distortion;16;91;33;100;102;99;94;95;103;92;59;98;110;223;37;39;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;99;-3940.953,619.481;Float;False;Property;_DistortionSpeedXYPowerZ;Distortion Speed XY Power Z;22;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;98;-3892.959,848.9976;Inherit;False;0;91;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;59;-3556.263,566.496;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-3508.142,654.5021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;116;201.7892,570.6976;Inherit;False;Constant;_Offset0;Offset0;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;179;-3564.244,-545.0338;Inherit;False;292.3999;254;CustomData;1;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;178;-1969.631,-1714.998;Inherit;False;1285.193;909.2882;Gradient;12;144;147;141;149;176;177;142;119;121;120;180;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;110;-3311.856,596.5295;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-3514.244,-495.0338;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;399.7139,573.3973;Inherit;False;Const_0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;113;-3238.325,-516.627;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;91;-3125.597,567.9764;Inherit;True;Property;_Noise;Noise;20;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;273;-3379.661,-722.5773;Inherit;False;274;Const_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;144;-1919.631,-1653.339;Inherit;False;Property;_ColorGradient;Size_Melt_漸層偏移(x,y);8;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;152;-3434.734,-620.3987;Inherit;False;Property;_Tex1Offset_uv_Alpha_w1;UseCustomData:Tex1Offset(x,y);12;1;[Toggle];Create;False;1;;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-3407.02,-271.2985;Inherit;False;1037.896;533.6285;Textures movement;8;107;108;21;89;22;15;29;96;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;33;-3119.033,763.0061;Inherit;True;Property;_NoiseMask;NoiseMask;21;0;Create;True;1;;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2734.872,550.0183;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-3529.605,748.0421;Float;False;Flowpower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;-1533.669,-1613.718;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;-3277.375,94.42903;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;151;-3003.57,-658.9441;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;366;-3129.598,406.1004;Inherit;False;Property;_CustomDataTex1_2Offset;讓CustomData一起控Tex1與2Offset;17;1;[Toggle];Create;False;1;;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;-2605.4,555.7643;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2619.471,652.2863;Inherit;False;102;Flowpower;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;15;-3267.833,-66.57865;Float;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;18;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;364;-2983.574,301.9795;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;319;-3135.639,1556.56;Inherit;False;Property;_DissSpeedxy;DissSpeed(x,y);25;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;142;-1277.326,-1662.499;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;320;-2815.603,1512.262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2972.226,-227.1099;Inherit;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;321;-2837.215,1231.983;Inherit;False;0;188;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;149;-1010.149,-1664.998;Inherit;False;Property;_Gradient;GradientMode;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Polar;Horizontal;Vertical;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-2359.726,465.7048;Inherit;False;274;Const_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-2319.038,655.387;Inherit;False;Property;_UseFlow;UseNoise;19;2;[Header];[Toggle];Create;False;1;NoiseTex;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-2361.657,542.6455;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2837.335,122.8439;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;365;-2707.194,312.0327;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;322;-2593.186,1312.175;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;200;-2175.311,1177.17;Inherit;False;958.1622;616.0454;硬溶解;11;188;218;236;248;238;237;239;345;346;249;199;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2843.819,-106.5443;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-2604.489,-449.248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;108;-2678.38,10.55958;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;177;-766.4376,-1513.611;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;222;-2194.182,561.8454;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-3250.977,-429.7518;Inherit;False;UV2_Z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;218;-2164.037,1251.618;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;176;-1236.55,-1477.554;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-2099.835,326.0031;Inherit;False;Property;_Tex2Value;Tex2Value;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;107;-2647.623,-167.3645;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;192;201.1034,508.2075;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-2288.359,79.92305;Inherit;True;Property;_Tex2;Tex2;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;367;-1947.94,220.3339;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-2399.261,-112.8518;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;188;-2051.94,1218.968;Inherit;True;Property;_DissolveTexture;DissolveTexture ;24;0;Create;True;0;0;0;False;0;False;-1;None;3f1d4fadb37c37e4488860109d7dce4b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;265;-3034.079,2177.36;Inherit;False;262;UV2_Z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;121;-1776.655,-1025.711;Float;False;Property;_Color2;Color2;5;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;194;-3075.463,2102.33;Inherit;False;Property;_DissolvePower;DissolvePower;26;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-3152.808,2256.522;Inherit;False;Property;_TexOffset_uv_Alpha_w2;UseCustomData:DissolvePower(z);27;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;141;-1632.026,-1452.526;Inherit;True;RadialGradient;-1;;1;ec972f7745a8353409da2eb8d000a2e3;0;3;1;FLOAT2;0,0;False;6;FLOAT;1.02;False;7;FLOAT;1.97;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;120;-1800.293,-1202.191;Float;False;Property;_Color1;Color1;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;386.9864,478.5192;Inherit;False;Const_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-1212.531,-890.8755;Inherit;False;Property;_Float0;使用漸層(Color2)?;6;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;371;-1825.381,212.5641;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-1749.971,-41.11976;Inherit;False;Property;_MainTex_Color;MainTex_Color;11;1;[Enum];Create;True;0;2;GrayScale;0;Color_RGBA;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-2238.376,-151.5643;Inherit;True;Property;_Main;Main;10;0;Create;True;1;;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;291;-1738.168,-195.9772;Inherit;False;287;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;215;-2777.533,2147.883;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-2067.058,-272.6344;Inherit;False;287;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;119;-1243.91,-1133.576;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-2192.52,1634.815;Inherit;False;Property;_Float3;硬邊溶解邊緣寬度;29;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;257;-2131.465,-462.4385;Float;False;Property;_Color3;Color3_(不要寫入Tex2顏色時,此欄調整成白色);14;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;345;-1773.031,1257.896;Inherit;False;DissTex_R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-1513.269,36.91755;Inherit;False;Property;_MainScale;MainScale;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;292;-1528.6,-128.5964;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;256;-1756.989,-321.7661;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;249;-1920.237,1547.088;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.48;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;32;-1623.552,625.1691;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;246;-2575.117,2159.772;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;180;-905.5397,-1106.291;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;-1856.785,1420.711;Inherit;False;345;DissTex_R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;313;827.5884,1018.949;Inherit;False;1048.303;940.0289;Mask;9;299;300;301;310;303;309;298;311;317;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1306.386,-156.5246;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;248;-2170.314,1434.385;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;335;-2175.471,2030.843;Inherit;False;941.6393;550.989;軟溶解1;10;332;325;329;334;324;326;328;327;323;347;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;-1750.207,1547.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;236;-1572.805,1249.661;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;237;-1627.118,1472.271;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;362;-868.4637,998.3895;Inherit;False;877.2937;685.6398;硬邊溶解顏色;5;361;226;225;355;240;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;298;877.5884,1737.001;Float;False;Property;_MaskSpeedXY;MaskSpeed XY_無zw;39;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-1112.651,-181.4539;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-2125.471,2404.597;Inherit;False;Property;_DissolveMaxValue;Soft_DissolveMaxValue;32;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;299;915.35,1554.984;Inherit;False;0;303;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;324;-1984.651,2172.959;Inherit;False;Property;_DissolveVaule;Soft_DissolveVaule;31;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;226;-818.4637,1475.029;Inherit;False;Property;_DissolveColor0;HardDissolveColor;30;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0.1231942,1;1,0,0.1231942,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;328;-1950.661,2277.49;Inherit;False;Constant;_Float2;Float 2;29;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-1925.405,2079.885;Inherit;False;345;DissTex_R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;238;-1411.698,1498.636;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;300;1163.067,1825.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-803.8221,1114.252;Inherit;False;360;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;329;-1870.78,2377.831;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-613.3978,1285.787;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-1619.428,2338.915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-1683.809,2124.378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-1700.877,2236.901;Inherit;False;287;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;301;1359.353,1767.205;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;36;-3130.713,961.4439;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;325;-1496.736,2167.125;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;225;-468.8333,1048.389;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;309;1363.782,1614.318;Inherit;False;Property;_MaskPower;MaskPower;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;-2738.073,843.4028;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-1326.224,1330.272;Inherit;False;Property;_Diss_Mode;Diss_Mode;28;1;[Enum];Create;True;0;2;Hard_Diss;0;Soft_Diss;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;303;1123.493,1241.57;Inherit;True;Property;_MaskTexture;MaskTexture;37;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2552.062,826.1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-1499.257,1016.487;Inherit;False;Property;_UseDissolve;UseDissolve;23;2;[Header];[Toggle];Create;True;1;DissTex;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;326;-1398.632,2080.842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;-1951.792,412.4938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;355;-173.1699,1247.751;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;1511.563,1498.83;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;314;703.9414,-38.27101;Inherit;False;1280.22;943.8776;頂點偏移;10;268;271;266;267;258;261;259;275;278;272;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;268;753.9414,242.8079;Inherit;False;Property;_VertexSpeedXY;Vertex Speed XY PowerZ;35;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;40;-2398.542,829.2438;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;354;-1180.898,1127.986;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;-1299.497,932.9717;Inherit;False;287;Const_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;231;-957.5708,-93.05165;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;311;1690.167,1534.697;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;372;-1806.839,413.8699;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;234;-1100.646,936.1569;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;72;-2238.267,825.2928;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;182;-1728.334,126.0237;Inherit;False;Property;_Tex1UseAtext;Tex1UseAtext;9;0;Create;True;0;0;0;False;1;Header(MainTex);False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;78;-793.1474,-71.03638;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;136;-835.1086,-505.5982;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;159;-1733.249,276.5958;Inherit;False;Property;_Tex2UseAtext;Tex2UseAtext;13;0;Create;True;0;0;0;False;1;;False;0;0;0;True;;KeywordEnum;2;RGBA;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;271;985.6278,229.8904;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-437.423,534.0858;Inherit;False;Property;_Alpha;Alpha;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;1623.904,1199.82;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;263;-3257.977,-359.7518;Inherit;False;UV2_W;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;266;869.3457,110.1697;Inherit;False;0;258;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;267;1105.458,164.6752;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-676.9078,112.0253;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-446.0907,153.7209;Float;False;Property;_Emission;Emission;0;1;[Header];Create;True;1;ColorGradient;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-482.5536,-156.4869;Inherit;False;263;UV2_W;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-342.2499,249.0659;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-172.2666,430.4857;Inherit;False;317;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-589.6514,-83.27936;Inherit;False;Property;_UseCustomDataEmissionw;UseCustomData:Emission(w);1;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;279;-194.7878,-221.5897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;261;1423.525,569.7867;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;316;-135.7623,195.7827;Inherit;False;Property;_UseMask;UseMask;36;2;[Header];[Toggle];Create;True;1;Mask;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-85.20616,315.8937;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;258;1269.792,129.642;Inherit;True;Property;_VertexTexture;VertexTexture;34;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;90;-536.6786,48.89112;Float;False;Property;_Usecenterglow;Use center glow?;40;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;1612.963,244.3863;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;278;1581.302,87.74246;Inherit;False;Property;_UseVertexMove;UseVertexMove;33;2;[Header];[Toggle];Create;True;1;Vertex;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;315;41.77541,210.5399;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;1568.231,11.72899;Inherit;False;274;Const_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-285.8404,56.42584;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;187;250.2933,674.3658;Inherit;False;Property;_CullMode;CullMode;42;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-123.9274,58.99411;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;114;241.7653,762.2928;Inherit;False;Property;_Zwrite;Zwrite;41;1;[Toggle];Create;True;0;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;272;1802.161,52.0569;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;152.8035,51.42049;Float;False;True;-1;2;;0;7;VFX/Blend3_CenterGlow;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;2;True;187;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;True;True;1;True;114;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;59;0;98;0
WireConnection;100;0;99;1
WireConnection;100;1;99;2
WireConnection;110;0;59;0
WireConnection;110;2;100;0
WireConnection;274;0;116;0
WireConnection;113;0;111;1
WireConnection;113;1;111;2
WireConnection;91;1;110;0
WireConnection;92;0;91;0
WireConnection;92;1;33;0
WireConnection;102;0;99;3
WireConnection;147;0;144;3
WireConnection;147;1;144;4
WireConnection;151;0;273;0
WireConnection;151;1;113;0
WireConnection;151;2;152;0
WireConnection;94;0;92;0
WireConnection;364;0;151;0
WireConnection;364;1;89;0
WireConnection;142;1;147;0
WireConnection;320;0;319;1
WireConnection;320;1;319;2
WireConnection;149;1;142;0
WireConnection;149;0;142;1
WireConnection;149;2;142;2
WireConnection;95;0;94;0
WireConnection;95;1;103;0
WireConnection;22;0;15;3
WireConnection;22;1;15;4
WireConnection;365;0;89;0
WireConnection;365;1;364;0
WireConnection;365;2;366;0
WireConnection;322;0;321;0
WireConnection;322;2;320;0
WireConnection;21;0;15;1
WireConnection;21;1;15;2
WireConnection;115;0;151;0
WireConnection;115;1;29;0
WireConnection;108;0;365;0
WireConnection;108;2;22;0
WireConnection;177;0;149;0
WireConnection;222;0;290;0
WireConnection;222;1;95;0
WireConnection;222;2;223;0
WireConnection;262;0;111;3
WireConnection;218;0;222;0
WireConnection;218;1;322;0
WireConnection;176;0;177;0
WireConnection;107;0;115;0
WireConnection;107;2;21;0
WireConnection;14;1;108;0
WireConnection;367;0;14;0
WireConnection;367;1;368;0
WireConnection;96;0;107;0
WireConnection;96;1;222;0
WireConnection;188;1;218;0
WireConnection;141;1;176;0
WireConnection;141;6;144;1
WireConnection;141;7;144;2
WireConnection;287;0;192;0
WireConnection;371;0;367;0
WireConnection;13;1;96;0
WireConnection;215;0;194;0
WireConnection;215;1;265;0
WireConnection;215;2;217;0
WireConnection;119;0;121;0
WireConnection;119;1;120;0
WireConnection;119;2;141;0
WireConnection;345;0;188;1
WireConnection;292;0;291;0
WireConnection;292;1;13;0
WireConnection;292;2;296;0
WireConnection;256;0;257;0
WireConnection;256;1;289;0
WireConnection;256;2;371;0
WireConnection;249;0;199;0
WireConnection;246;0;215;0
WireConnection;180;0;120;0
WireConnection;180;1;119;0
WireConnection;180;2;181;0
WireConnection;30;0;292;0
WireConnection;30;1;256;0
WireConnection;30;2;180;0
WireConnection;30;3;32;0
WireConnection;30;4;251;0
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
WireConnection;300;0;298;1
WireConnection;300;1;298;2
WireConnection;329;0;246;0
WireConnection;329;4;332;0
WireConnection;240;0;361;0
WireConnection;240;1;238;0
WireConnection;240;2;226;0
WireConnection;327;0;329;0
WireConnection;327;1;328;0
WireConnection;323;0;347;0
WireConnection;323;1;324;0
WireConnection;301;0;299;0
WireConnection;301;2;300;0
WireConnection;36;0;98;3
WireConnection;325;0;323;0
WireConnection;325;1;327;0
WireConnection;325;2;334;0
WireConnection;225;0;361;0
WireConnection;225;1;240;0
WireConnection;225;2;238;0
WireConnection;37;0;33;0
WireConnection;37;1;36;0
WireConnection;303;1;301;0
WireConnection;39;0;33;0
WireConnection;39;1;37;0
WireConnection;326;0;325;0
WireConnection;369;0;14;4
WireConnection;369;1;368;0
WireConnection;355;0;225;0
WireConnection;355;1;361;0
WireConnection;355;2;353;0
WireConnection;310;0;303;1
WireConnection;310;1;309;0
WireConnection;40;0;39;0
WireConnection;354;0;237;0
WireConnection;354;1;326;0
WireConnection;354;2;353;0
WireConnection;231;0;360;0
WireConnection;231;1;355;0
WireConnection;231;2;233;0
WireConnection;311;0;310;0
WireConnection;372;0;369;0
WireConnection;234;0;288;0
WireConnection;234;1;354;0
WireConnection;234;2;233;0
WireConnection;72;0;40;0
WireConnection;182;1;13;0
WireConnection;182;0;13;4
WireConnection;78;0;231;0
WireConnection;136;0;119;0
WireConnection;159;1;371;0
WireConnection;159;0;372;0
WireConnection;271;0;268;1
WireConnection;271;1;268;2
WireConnection;317;0;311;0
WireConnection;263;0;111;4
WireConnection;267;0;266;0
WireConnection;267;2;271;0
WireConnection;41;0;78;0
WireConnection;41;1;72;0
WireConnection;88;0;182;0
WireConnection;88;1;159;0
WireConnection;88;2;234;0
WireConnection;88;3;136;0
WireConnection;88;4;32;4
WireConnection;88;5;255;0
WireConnection;279;0;52;0
WireConnection;279;1;264;0
WireConnection;279;2;281;0
WireConnection;312;0;88;0
WireConnection;312;1;318;0
WireConnection;258;1;267;0
WireConnection;90;0;78;0
WireConnection;90;1;41;0
WireConnection;259;0;258;0
WireConnection;259;1;268;3
WireConnection;259;2;261;0
WireConnection;315;0;88;0
WireConnection;315;1;312;0
WireConnection;315;2;316;0
WireConnection;51;0;90;0
WireConnection;51;1;279;0
WireConnection;87;0;51;0
WireConnection;87;3;315;0
WireConnection;272;0;275;0
WireConnection;272;1;259;0
WireConnection;272;2;278;0
WireConnection;68;0;87;0
WireConnection;68;1;272;0
ASEEND*/
//CHKSM=B7ED888E6C297F493231F001108612342F64BDC4