Shader "Outline/AdvOutline_Instancing"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _Outline ("Outline Width", Range(0.002, 1)) = .005
    }
    SubShader
    {

         Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID // use this to access instanced properties in the fragment shader.
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }

        Pass {
        
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID // use this to access instanced properties in the fragment shader.
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float, _Outline)
                UNITY_DEFINE_INSTANCED_PROP(float4, _OutlineColor)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.pos = UnityObjectToClipPos(v.vertex);

                // 根據世界位置計算法線並將其乘以該值
                // UNITY_MATRIX_IT_MV 提供該值
                // 它以世界座標的形式傳回法線，而不是所屬的法線
                float3 norm = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV,
                v.normal));

                // 根據法線 xy 位置透過將其轉換為投影來計算偏移
                float2 offset = TransformViewToProjection(norm.xy);

                o.pos.xy += offset * o.pos.z * UNITY_ACCESS_INSTANCED_PROP(Props, _Outline);
                o.color = UNITY_ACCESS_INSTANCED_PROP(Props, _OutlineColor);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
