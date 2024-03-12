Shader "Lava Flowing Shader/Diffuse/Lava_Flowing_OnlyLavaTex_2" 
{
	Properties 
	{
		_DistortX ("Distortion in X", Range (0,2)) = 1
		_DistortY ("Distortion in Y", Range (0,2)) = 0
		_Speed("Scroll Speed",Range(-4,4))=1
		_Distort ("_Distort A", 2D) = "white" {}
		_LavaTex ("_LavaTex RGB", 2D) = "white" {}
	}
	SubShader 
	{

		Tags { "RenderType"="Opaque" "Queue" = "TransParent" }
		LOD 150

			ZWrite Off
			CGPROGRAM
			#pragma surface surf Lambert

			sampler2D _Distort;
			sampler2D _LavaTex;
			fixed _DistortX;
			fixed _DistortY;
			fixed _Speed;

			struct Input 
			{
				float2 uv2_LavaTex;
			};

			void surf (Input IN, inout SurfaceOutput o) 
			{
				fixed distort = tex2D(_Distort, IN.uv2_LavaTex).a;

				fixed2 uv_scroll;
				uv_scroll = fixed2(IN.uv2_LavaTex.x-distort*_DistortX,IN.uv2_LavaTex.y-distort*_DistortY);
				
				fixed2 scrollValue = fixed2(_Speed,0) * _Time;

				fixed4 tex2 = tex2D(_LavaTex,uv_scroll - scrollValue);
				o.Albedo = tex2.rgb;
				o.Alpha = tex2.a;
			}
			ENDCG
}

Fallback "Mobile/VertexLit"
}
