Shader "Unlit/StirBarAddColor"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (.4,.4,.4,1)
        _StirColorRed ("Stir Area Red", Color) = (1,0.15,0.1,1)
        _StirRedMaxRange ("Stir Red Max Range", Range(0, 1)) = .9
        _StirRedMinRange ("Stir Red Min Range", Range(0, 1)) = .5
        _StirColorGreen ("Stir Area Green", Color) = (.2, 1,0.1,1)
        _StirGreenMaxRange ("Stir Green Max Range", Range(0, 1)) = .8
        _StirGreenMinRange ("Stir Green Min Range", Range(0, 1)) = .3
        _StirColorBlue ("Stir Area Blue", Color) = (.1, .1, 1, 1)
        _StirBlueMaxRange ("Stir Blue Max Range", Range(0, 1)) = .5
        _StirBlueMinRange ("Stir Blue Min Range", Range(0, 1)) = 0
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
        Blend SrcAlpha OneMinusSrcAlpha
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
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _StirColorRed;
            float _StirRedMaxRange;
            float _StirRedMinRange;
            fixed4 _StirColorGreen;
            float _StirGreenMaxRange;
            float _StirGreenMinRange;
            fixed4 _StirColorBlue;
            float _StirBlueMaxRange;
            float _StirBlueMinRange;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            float Lerp(float a, float b, float t)
            {
                return (1 - t) * a + b * t;
            }

            float InvLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            float Remap(float iMin, float iMax, float oMin, float oMax, float v)
            {
                float t = InvLerp(iMin, iMax, v);
                return Lerp(oMin, oMax, t);
                    
            }

            float3 blendAdd(float3 base, float3 blend) 
            {
                return min(base+blend, float3(1, 1, 1));
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                //OUT.color = v.color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirRedMinRange) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirRedMaxRange) ? _StirColorRed : _Color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirGreenMinRange) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirGreenMaxRange) ? _StirColorGreen : color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirBlueMinRange) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirBlueMaxRange) ? _StirColorBlue : color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirGreenMinRange > _StirRedMinRange ? _StirGreenMinRange : _StirRedMinRange
                ) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirGreenMaxRange > _StirRedMaxRange ? _StirRedMaxRange : _StirGreenMaxRange) ?
                half4(blendAdd(_StirColorGreen.rgb, _StirColorRed.rgb), 1) : color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirGreenMinRange > _StirBlueMinRange ? _StirGreenMinRange : _StirBlueMinRange
                ) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirGreenMaxRange > _StirBlueMaxRange ? _StirBlueMaxRange : _StirGreenMaxRange) ?
                half4(blendAdd(_StirColorGreen.rgb, _StirColorBlue.rgb), 1) : color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirRedMinRange > _StirBlueMinRange ? _StirRedMinRange : _StirBlueMinRange
                ) && IN.texcoord.x < Remap(0, 1, .3, .7, _StirRedMaxRange > _StirBlueMaxRange ? _StirBlueMaxRange : _StirRedMaxRange) ?
                half4(blendAdd(_StirColorRed.rgb, _StirColorBlue.rgb), 1) : color;

                color = IN.texcoord.x > Remap(0, 1, .3, .7, _StirRedMinRange > _StirBlueMinRange ? _StirRedMinRange  > _StirGreenMinRange ? _StirRedMinRange : _StirGreenMinRange 
                : _StirBlueMinRange  > _StirGreenMinRange ? _StirBlueMinRange : _StirGreenMinRange) && 
                IN.texcoord.x < Remap(0, 1, .3, .7, _StirRedMaxRange > _StirBlueMaxRange ? _StirGreenMaxRange > _StirBlueMaxRange ? _StirBlueMaxRange : _StirGreenMaxRange 
                : _StirGreenMaxRange > _StirRedMaxRange ? _StirRedMaxRange : _StirGreenMaxRange) ?
                half4(blendAdd(blendAdd(_StirColorRed.rgb, _StirColorBlue.rgb), _StirColorGreen.rgb), 1) : color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
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
