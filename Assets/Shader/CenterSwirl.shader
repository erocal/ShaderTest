// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/CenterSwirl"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_radius("radius", Float) = 0.9
		_center("center", Vector) = (0.5,0.5,0,0)
		_strength("strength", Float) = 7.29
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow nofog 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float3 _center;
		uniform float _radius;
		uniform float _strength;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float temp_output_13_0 = ( distance( float3( uv_MainTex ,  0.0 ) , _center ) * 2.0 );
			float temp_output_24_0 = ( 1.0 - ( temp_output_13_0 / _radius ) );
			float cos23 = cos( ( ( temp_output_24_0 * temp_output_24_0 ) * _strength ) );
			float sin23 = sin( ( ( temp_output_24_0 * temp_output_24_0 ) * _strength ) );
			float2 rotator23 = mul( uv_MainTex - _center.xy , float2x2( cos23 , -sin23 , sin23 , cos23 )) + _center.xy;
			float2 lerpResult17 = lerp( uv_MainTex , rotator23 , ( temp_output_13_0 < _radius ? 1.0 : 0.0 ));
			o.Emission = tex2D( _MainTex, lerpResult17 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1880.126,62.58262;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;12;-1622.935,147.9593;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1452.099,143.6441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1859.762,392.842;Inherit;False;Property;_radius;radius;1;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;11;-1862.212,212.1158;Inherit;False;Property;_center;center;2;0;Create;True;0;0;0;False;0;False;0.5,0.5,0;0.5,0.5,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Compare;14;-868.0651,188.1902;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-457.5266,204.2438;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;23;-780.4172,441.0581;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-1469.226,406.6522;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-1283.664,469.4171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1131.59,477.2361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-980.3733,553.1668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1859.614,513.21;Inherit;False;Property;_strength;strength;3;0;Create;True;0;0;0;False;0;False;7.29;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-201.2116,-5.244333;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;78c45824a1cac43269876962321a1680;78c45824a1cac43269876962321a1680;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;34;100.8822,-17.2238;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Custom/CenterSwirl;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-2125.03,-62.62121;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;78c45824a1cac43269876962321a1680;78c45824a1cac43269876962321a1680;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;7;2;9;0
WireConnection;12;0;7;0
WireConnection;12;1;11;0
WireConnection;13;0;12;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;17;0;7;0
WireConnection;17;1;23;0
WireConnection;17;2;14;0
WireConnection;23;0;7;0
WireConnection;23;1;11;0
WireConnection;23;2;26;0
WireConnection;18;0;13;0
WireConnection;18;1;15;0
WireConnection;24;0;18;0
WireConnection;25;0;24;0
WireConnection;25;1;24;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;8;0;9;0
WireConnection;8;1;17;0
WireConnection;34;2;8;0
ASEEND*/
//CHKSM=BF9B17B5307F6473CE281E4DC47F961A6A006BB5