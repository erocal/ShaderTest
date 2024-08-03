Shader "Custom/Lava" 
{
Properties 
{
	_DistortX ("Distortion in X", Range (0,2)) = 1
	_DistortY ("Distortion in Y", Range (0,2)) = 0
	_Speed("Scroll Speed",Range(-4,4))=1

	_MainTex ("_MainTex RGBA", 2D) = "white" {}
	_NormalTex ("Normal Map", 2D) = "bump" {}
    _NormalIntensity ("Normal Map Intensity", Range(0,2)) = 1

	_Distort ("_Distort A", 2D) = "white" {}
	
	_LavaTex ("_LavaTex RGB", 2D) = "white" {}
	_LavaNormalTex ("Normal Map", 2D) = "bump" {}
	_LavaNormalIntensity ("Normal Map Intensity", Range(0,2)) = 1

	
}
SubShader 
{
	Tags { "RenderType"="Opaque" }
	LOD 150

	CGPROGRAM
	#pragma surface surf Lambert noforwardadd

	sampler2D _MainTex;
	sampler2D _NormalTex;
	sampler2D _Distort;
	sampler2D _LavaTex;
	sampler2D _LavaNormalTex;

	fixed _DistortX;
	fixed _DistortY;
	fixed _Speed;
	fixed _NormalIntensity;
	fixed _LavaNormalIntensity;

	struct Input 
	{
		float2 uv2_LavaTex;
		float2 uv_MainTex;
		float2 uv2_LavaNormalTex;
		float2 uv_NormalTex;
	};



	void surf (Input IN, inout SurfaceOutput o) 
	{
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		fixed distort = tex2D(_Distort, IN.uv_MainTex).a;

		//岩浆挤压
		fixed scrollDir = _Speed>0?-1:1;
		fixed2 lavaDistort = fixed2(IN.uv2_LavaTex.x + distort *scrollDir *_DistortX,IN.uv2_LavaTex.y + distort*_DistortY * scrollDir);

		// UV卷动
		fixed2 scrollValue = fixed2(_Speed,0) * _Time;
		fixed4 tex2 = tex2D(_LavaTex,lavaDistort + scrollValue);

		//法线
		float3 mainNormalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
		mainNormalMap = float3(mainNormalMap.x * _NormalIntensity,mainNormalMap.y * _NormalIntensity,mainNormalMap.z);

		float3 lavaNormalMap = UnpackNormal(tex2D(_LavaNormalTex, lavaDistort + scrollValue));
		lavaNormalMap = float3(lavaNormalMap.x * _LavaNormalIntensity,lavaNormalMap.y * _LavaNormalIntensity,lavaNormalMap.z);

		c.rgb = lerp(tex2.rgb,c.rgb,c.a);
		
		o.Albedo = c.rgb;
		o.Normal = lerp(lavaNormalMap,mainNormalMap,c.a);
		o.Albedo = c.rgb*c.a;
		o.Albedo += c.rgb*(1-c.a)* 0.5;
		o.Emission = c.rgb*(1-c.a);
		
		o.Alpha = c.a;
		
	}

	ENDCG
}

FallBack "Specular"
}