// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "cz_03EmissDiss"
{
	Properties
	{
		_Maintex("Maintex", 2D) = "white" {}
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_EdigeWidth("EdigeWidth", Float) = 0.27
		_Dissolve("Dissolve", Range( 0 , 1.05)) = 0.5435294
		[HDR]_EdgeColor("EdgeColor", Color) = (0.9811321,0.7821289,0.1843137,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
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
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Maintex;
			uniform float4 _Maintex_ST;
			uniform float _Dissolve;
			uniform sampler2D _DissolveTex;
			uniform float4 _DissolveTex_ST;
			uniform float _EdigeWidth;
			uniform float4 _EdgeColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 uv_Maintex = i.ase_texcoord1.xy * _Maintex_ST.xy + _Maintex_ST.zw;
				float4 tex2DNode1 = tex2D( _Maintex, uv_Maintex );
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 tex2DNode2 = tex2D( _DissolveTex, uv_DissolveTex );
				float temp_output_6_0 = step( _Dissolve , ( tex2DNode2.r + _EdigeWidth ) );
				float temp_output_9_0 = ( temp_output_6_0 - step( _Dissolve , tex2DNode2.r ) );
				float4 temp_output_5_0 = ( tex2DNode1.a * temp_output_9_0 * _EdgeColor );
				float4 appendResult14 = (float4((( tex2DNode1 + float4( 0,0,0,0 ) + temp_output_5_0 )).rgba.rgb , ( tex2DNode1.a * temp_output_6_0 )));
				
				
				finalColor = appendResult14;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
51.2;67.2;1536;663;1251.51;920.8378;2.094024;True;True
Node;AmplifyShaderEditor.SamplerNode;2;-729.7614,109.2432;Inherit;True;Property;_DissolveTex;DissolveTex;1;0;Create;True;0;0;0;False;0;False;-1;17c41b7cd86353543b0f58d55b1f1f5b;17c41b7cd86353543b0f58d55b1f1f5b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-727.7757,360.9507;Inherit;False;Property;_EdigeWidth;EdigeWidth;2;0;Create;True;0;0;0;False;0;False;0.27;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-443.1279,306.9998;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-716.7614,3.243168;Inherit;False;Property;_Dissolve;Dissolve;3;0;Create;True;0;0;0;False;0;False;0.5435294;0.5435294;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;6;-181.5541,261.3732;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;3;-411.7614,4.243168;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-103.9708,-13.064;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-473.3292,-748.2089;Inherit;True;Property;_Maintex;Maintex;0;0;Create;True;0;0;0;False;0;False;-1;d01211215348df14cb25d942a4348378;d01211215348df14cb25d942a4348378;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-531.3848,-401.188;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0.9811321,0.7821289,0.1843137,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-238.1517,-394.2106;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;210.619,-733.9257;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;478.1922,21.90129;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;15;521.3486,-440.0141;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;793.2285,-377.3676;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;13;200.0414,-415.3377;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1288.096,-276.4365;Float;False;True;-1;2;ASEMaterialInspector;100;1;cz_03EmissDiss;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;8;0;2;1
WireConnection;8;1;7;0
WireConnection;6;0;4;0
WireConnection;6;1;8;0
WireConnection;3;0;4;0
WireConnection;3;1;2;1
WireConnection;9;0;6;0
WireConnection;9;1;3;0
WireConnection;5;0;1;4
WireConnection;5;1;9;0
WireConnection;5;2;11;0
WireConnection;17;0;1;0
WireConnection;17;2;5;0
WireConnection;16;0;1;4
WireConnection;16;1;6;0
WireConnection;15;0;17;0
WireConnection;14;0;15;0
WireConnection;14;3;16;0
WireConnection;13;0;1;0
WireConnection;13;1;5;0
WireConnection;13;2;9;0
WireConnection;0;0;14;0
ASEEND*/
//CHKSM=04B80D1619F9E08F1D8A868ADBF26B60394C33BE