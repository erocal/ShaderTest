Shader "Custom/Occlusion_Instancing"
{
    Properties
    {
        // 被遮擋的部分
        _Color ("Occlusion Color", Color) = (1,1,1,1) // 控制遮擋效果的顏色
        _Width ("Occlusion Width", Range(0,10)) = 1 // 控制邊緣高亮的寬度
        _Intensity("Occlusion Intensity", Range(0, 10)) = 1 // 控制高亮的強度

        // 未被遮擋的部分
        _Albedo("Albedo", 2D) = "white"{} // 漫反射貼圖
        _Specular("Specular (RGB-A)", 2D) = "black"{} // 高光貼圖（包括RGB和Alpha通道）
        _Normal("Nromal", 2D) = "bump"{} // 法線貼圖
        _AO("AO", 2D) = "white"{} // 環境光遮擋貼圖
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Pass
        {
            ZTest Greater // 有物體擋住時會走這個通道
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha // 使用普通的透明混合方式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 worldPos : SV_POSITION;
                float3 viewDir : TEXCOORD0;
                float3 worldNor : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(fixed, _Width)
                UNITY_DEFINE_INSTANCED_PROP(half, _Intensity)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(appdata_base v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.worldPos = UnityObjectToClipPos(v.vertex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.worldNor = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {

                UNITY_SETUP_INSTANCE_ID(i);

                // 計算光線入射法線的點積，並將其映射到遮擋值

                // 計算了光線的方向向量與表面法線向量之間的點積，通過 saturate 函數將結果限制在0到1之間
                // 這樣計算後會得到中間白邊緣黑的效果
                half NDotV = saturate( dot(i.worldNor, i.viewDir));

                // 用1減去NDotV，就能達到反相效果，會變成邊緣白中間黑
                // 使用pow函數控制邊緣的寬度，接著乘以_Intensity控制邊緣的亮度
                NDotV = pow(1 - NDotV, UNITY_ACCESS_INSTANCED_PROP(Props, _Width)) * UNITY_ACCESS_INSTANCED_PROP(Props, _Intensity);

                fixed4 color;
                color.rgb = UNITY_ACCESS_INSTANCED_PROP(Props, _Color).rgb;
                color.a = NDotV; // 輸入近透明層，實現半透效果
                return color;
            }
            ENDCG
        }

        CGPROGRAM
        #pragma surface surf StandardSpecular
        #pragma target 3.0

        struct Input
        {
            float2 uv_Albedo;
        };

        sampler2D _Albedo;
        sampler2D _Specular;
        sampler2D _Normal;
        sampler2D _AO;

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            // 從貼圖中取得漫反射顏色
            o.Albedo = tex2D(_Albedo, IN.uv_Albedo).rgb;

            // 從高光貼圖中取得高光顏色和平滑度
            fixed4 specular = tex2D(_Specular, IN.uv_Albedo);
            o.Specular = specular.rgb;
            o.Smoothness = specular.a;

            // 從法線貼圖中解碼法線信息
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Albedo));

            // 從環境光遮擋貼圖中取得環境光遮擋值
            o.Occlusion = tex2D(_AO, IN.uv_Albedo).a;
        }
        ENDCG
    }
    Fallback "Diffuse"
}
