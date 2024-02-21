Shader "Custom/PlanarReflectionFloor"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _BumpTex ("Bump Texture", 2D) = "bump" {}
        _BumpSlider ("Bump Amount", Range(0,10)) = 0.2
        _TextureBumpSlider ("Texture Bump Amount", Range(0,2)) = 1
        _ReflectionFactor("ReflectionFactor",Range(0,10)) = 0.5
        _ReflectionColor ("ReflectionColor", Color) = (1,1,1,1)
        [Hide]_ReflectionTex("ReflectionTex",2D) = "White"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //#pragma surface surf Standard fullforwardshadows
        #pragma surface surf Standard fullforwardshadows
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
        sampler2D _ReflectionTex;
        sampler2D _BumpTex;
        half _TextureBumpSlider;
        
 
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpTex;
            float4 screenPos;
        };

        half _BumpSlider;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _ReflectionColor;
        float _ReflectionFactor;
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv = IN.screenPos.xy / IN.screenPos.w;
            uv.x = 1 - uv.x;

            fixed4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex) * _Color * (1.0 - _ReflectionFactor); // 主紋理顏色
            fixed4 reflectionColor = tex2D(_ReflectionTex, uv) * _ReflectionFactor * _ReflectionColor; // 反射的顏色，同時乘以 _ReflectionFactor 調整強度

            // 添加一个 smoothstep 方法，控制 reflectionColor 只留取白色部分
            float blendFactor = smoothstep(0.4, 1.0, reflectionColor.r); // 調整參數以控制疊加的範圍

            // 將_MainTex的顏色和反射的顏色進行疊加
            fixed4 finalColor = mainTexColor + reflectionColor * blendFactor;

            o.Albedo = finalColor.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex) * _TextureBumpSlider);
            o.Normal *= float3(_BumpSlider, _BumpSlider, 1);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = finalColor.a;

        }
        ENDCG
    }
    FallBack "Diffuse"
}