Shader "Holistic/AdvOutline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _Outline ("Outline Width", Range(0.002, 1)) = .005
    }
    SubShader
    {

        CGPROGRAM

            #pragma surface surf Lambert
            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;

            void surf (Input IN, inout SurfaceOutput o)
            {
                o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            }

        ENDCG

        Pass {
        
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
            };

            float _Outline;
            float4 _OutlineColor;

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 根據世界位置計算法線並將其乘以該值
                // UNITY_MATRIX_IT_MV 提供該值
                // 它以世界座標的形式傳回法線，而不是所屬的法線
                float3 norm = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV,
                v.normal));

                // 根據法線 xy 位置透過將其轉換為投影來計算偏移
                float2 offset = TransformViewToProjection(norm.xy);

                o.pos.xy += offset * o.pos.z * _Outline;
                o.color = _OutlineColor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
