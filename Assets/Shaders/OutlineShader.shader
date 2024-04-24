﻿Shader "Holistic/SimpleOutline" {

	Properties {

		_MainTex("Main Texture", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Outline("Outline Width", Range(0.002, 0.1)) = 0.005
	}

	SubShader {

		ZWrite Off
		CGPROGRAM
			#pragma surface surf Lambert vertex:vert

			struct Input {
			
				float2 uv_MainTex;
			};

			float _Outline;
			float4 _OutlineColor;

			void vert(inout appdata_full v) {

				v.vertex.xyz += v.normal * _Outline;
			}

			void surf(Input IN, inout SurfaceOutput o) {

				o.Emission = _OutlineColor.rgb;
			}
		ENDCG

		ZWrite On
		CGPROGRAM
		#pragma surface surf Lambert

			struct Input {

				float2 uv_MainTex;
			};

			sampler2D _MainTex;

			void surf(Input IN, inout SurfaceOutput o) {

				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			}
		ENDCG
	}
	FallBack "Diffuse"
}