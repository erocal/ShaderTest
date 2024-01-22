Shader "Custom/FloorTotal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _myBump ("Bump Texture", 2D) = "bump" {}
        _mySlider ("Bump Amount", Range(0,10)) = 0.2
        _myTextureBumpSlider ("Texture Bump Amount", Range(0,2)) = 1
        _ReflectionFactor("ReflectionFactor",Range(0,1)) = 0.5
        [Hide]_ReflectionTex("ReflectionTex",2D) = "White"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}
        LOD 200
 
        Stencil{
                Ref 1
                Comp always
                Pass replace
        }
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma surface surf Lambert
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
        sampler2D _ReflectionTex;
        sampler2D _myBump;
        half _myTextureBumpSlider;
        
 
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_myBump;
            float4 screenPos;
        };

        half _mySlider;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
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
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color * (1 - _ReflectionFactor) +  _ReflectionFactor * tex2D(_ReflectionTex,uv);
            o.Albedo = c.rgb * _myTextureBumpSlider;
            o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump) * _myTextureBumpSlider); // �NBump Texture��rgb�ഫ���k�u�K�Ϫ�xyz
            o.Normal *= float3(_mySlider,_mySlider,1);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}