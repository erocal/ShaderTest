Shader "Holistic/RimLighting" {

	Properties {

		_RimColor("Rim Color", Color) = (0.0, 0.5, 0.5, 0.0)
		_RimPower("Rim Power", Range(0.5, 8.0)) = 3.0
		_StripeSize("Stipe Size", Range(0.1, 0.9)) = 0.5
	}

	SubShader {

		CGPROGRAM
			#pragma surface surf Lambert

			struct Input {
			
				float3 viewDir;
				float3 worldPos;
			};

			fixed4 _RimColor;
			float _RimPower;
			float _StripeSize;

			void surf(Input IN, inout SurfaceOutput o) {

				half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
				o.Emission = frac(IN.worldPos.y * 10 * _StripeSize) > 0.4 ? float3(0, 1, 0) * rim : float3(1, 0, 0) * rim;
			}
		ENDCG
	}
	FallBack "Diffuse"
}