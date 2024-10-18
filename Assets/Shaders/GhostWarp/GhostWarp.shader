Shader "UI/GhostWarp"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Opacity("Opacity", range(0.0, 1.0)) = 0.5
        _WarpTex("Warp Texture", 2D) = "white"{}    //rg通道控制UV方向的扭曲，b通道為noise，這樣可以少採樣一張貼圖
        _WarpMul("Warp Multiply", range(0.0, 5.0)) = 1.0
        _NoiseMul("Noise Multiply", range(0.0,5.0)) = 1.0
        _FlowSpeed("Flow Speed", range(-10.0,10.0)) = 5.0

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "ForceNoShadowCasting"="True"        //關閉陰影投射
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float2 texcoord2 : TEXCOORD2;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            uniform half _Opacity;
            uniform sampler2D _WarpTex; uniform float4 _WarpTex_ST;
            uniform half _WarpMul;
            uniform half _NoiseMul;
            uniform half _FlowSpeed;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;
                OUT.texcoord2 = TRANSFORM_TEX(v.texcoord, _WarpTex);    //UV1支持TillingOffset
                OUT.texcoord2.x = OUT.texcoord2.x + frac(-_Time.x * _FlowSpeed);   //V軸方向隨時間流動,frac()取餘數

                OUT.color = v.color;
                return OUT;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                half3 var_WarpTex = tex2D(_WarpTex, i.texcoord2).rgb;

                float2 uvBias = (var_WarpTex.rg - 0.5) * _WarpMul;  //計算UV偏移值，讓擾動區間在-0.5~0.5
                float2 uv0 = i.texcoord + uvBias;                        //應用UV偏移值
                half4 var_MainTex = tex2D(_MainTex, uv0);           //使用偏移UV採樣MainTex

                half3 finalRGB = var_MainTex.rgb;
                half noise = lerp(1.0, var_WarpTex.b * 2.0, _NoiseMul);    //remap範圍
                noise = max(0.0, noise);                                 //截斷負值
                half opacity = var_MainTex.a * _Opacity * noise;

                half4 color = half4(finalRGB * opacity, opacity);

                //half4 color = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd) * i.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}