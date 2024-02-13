Shader "Holistic/HelloShader" {

	Properties {
		_myColor ("Example Colour", Color) = (1,1,1,1)
		_myNormal ("Example Normal", Color) = (1,1,1,1)
		_myEmission ("Example Emission", Color) = (1,1,1,1)
	}

	SubShader {
	
		CGPROGRAM
			#pragma surface surf Lambert

			struct Input {
				float2 uvMainTex;
			};

			fixed4 _myColor;
			fixed4 _myNormal;
			fixed4 _myEmission;

			void surf (Input IN, inout SurfaceOutput o){
				o.Albedo = _myColor.rgb;
				o.Emission = _myEmission.rgb;
				o.Normal = _myNormal;
			}

		ENDCG
	}

	FallBack "Diffuse"
}