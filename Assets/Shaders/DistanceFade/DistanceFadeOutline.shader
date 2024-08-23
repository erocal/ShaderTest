/// Thanks to Ronja Böhringer made some of this code

Shader "Custom/DistanceFadeOutline"
{
    //show values to edit in inspector
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [NoScaleOffset]_DitherPattern ("Dithering Pattern", 2D) = "white" {}
        _MinDistance ("Minimum Fade Distance", Float) = 10
        _OutlineMinDistance ("Outline Minimum Fade Distance", Float) = 10
        _MaxDistance ("Maximum Fade Distance", Float) = 15
        _OutlineMaxDistance ("Outline Maximum Fade Distance", Float) = 45
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _Outline ("Outline Width", Range(0.002, 1)) = .005
    }

    SubShader {
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Opaque" "Queue"="Transparent"}

        CGPROGRAM

        //the shader is a surface shader, meaning that it will be extended by unity in the background to have fancy lighting and other features
        //our surface shader function is called surf and we use our custom lighting model
        #pragma surface surf Standard
        #pragma target 3.0
        #include "UnityCG.cginc"
        #include "Assets\Cginc\DistanceFade.cginc"

        //texture and tint of color
        sampler2D _MainTex;
        float4 _Color;

        //remapping of distance
        float _MinDistance;
        float _MaxDistance;

        //The dithering pattern
        sampler2D _DitherPattern;
        float4 _DitherPattern_TexelSize;

        //input struct which is automatically filled by unity
        struct Input {
            float2 uv_MainTex;
            float4 screenPos;
        };

        //the surface shader function which sets parameters the lighting function then uses
        void surf (Input i, inout SurfaceOutputStandard o) {
            //read texture and write it to diffuse color
            float3 texColor = tex2D(_MainTex, i.uv_MainTex);
            o.Albedo = texColor.rgb * _Color;

            
            //discard pixels accordingly
            clip(DistanceFadeClip(i.screenPos, _DitherPattern, _DitherPattern_TexelSize, _MinDistance, _MaxDistance));
        }
        ENDCG

        Pass {
        
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets\Cginc\DistanceFade.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                fixed4 color : COLOR;
            };

            sampler2D _DitherPattern;
            float4 _DitherPattern_TexelSize;

            //remapping of distance
            float _OutlineMinDistance;
            float _OutlineMaxDistance;

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

                o.screenPos = ComputeScreenPos(o.pos);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                clip(DistanceFadeClip(i.screenPos, _DitherPattern, _DitherPattern_TexelSize, _OutlineMinDistance, _OutlineMaxDistance));

                return i.color;

            }
            ENDCG
        }
    }
}
