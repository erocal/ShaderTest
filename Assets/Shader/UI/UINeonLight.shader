Shader "Unlit/UINeonLight"
{
    Properties 
    {
        _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
        [Toggle]_UseLightTex("UseLightTex", Float) = 0
        _TriangleLightTex ("TriangleLight Texture", 2D) = "white" {}
        [Toggle]_UseSingleLightTexture("Use SingleLight Texture", Float) = 0
        _SingleLightTex ("SingleLight Texture", 2D) = "white" {}
        _SingleLightTex2 ("SingleLight Texture2 Offset", Vector) = (1, 1, 0, 0)
        _SingleLightTex3 ("SingleLight Texture3 Offset", Vector) = (1, 1, 0, 0)
        _SingleLightTex4 ("SingleLight Texture4 Offset", Vector) = (1, 1, 0, 0)
        _SingleLightTex5 ("SingleLight Texture5 Offset", Vector) = (1, 1, 0, 0)
        _SingleLightTex6 ("SingleLight Texture6 Offset", Vector) = (1, 1, 0, 0)
        _SingleLightTex7 ("SingleLight Texture7 Offset", Vector) = (1, 1, 0, 0)
        [HideInInspector]_TriangleLightTextureScrollSpeed("TriangleLight Scroll Speed", Range(0,1)) = 1
        [HideInInspector]_SingleLightTextureScrollSpeed("SingleLight Scroll Speed", Range(0,1)) = 1
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
    Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
    LOD 100

    Lighting Off

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_fog

            #include "UnityCG.cginc" 

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord2 : TEXCOORD1;
                float2 texcoord3 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord2 : TEXCOORD1;
                float2 texcoord3 : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _TriangleLightTex;
            sampler2D _SingleLightTex;
            float2 _SingleLightTex2;
            float2 _SingleLightTex3;
            float2 _SingleLightTex4;
            float2 _SingleLightTex5;
            float2 _SingleLightTex6;
            float2 _SingleLightTex7;

            fixed _TriangleLightTextureScrollSpeed;
            fixed _SingleLightTextureScrollSpeed;

            float4 _MainTex_ST;
            float4 _TriangleLightTex_ST;
            float4 _SingleLightTex_ST;
            fixed _Cutoff;

            uniform float _UseLightTex;
            uniform float _UseSingleLightTexture;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.texcoord2 = TRANSFORM_TEX(v.texcoord2, _TriangleLightTex);
                o.texcoord3 = TRANSFORM_TEX(v.texcoord3, _SingleLightTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = tex2D(_MainTex, i.texcoord);

                clip(col.a - _Cutoff);
                
                float2 _TriangleLightTextureScrollValue = float2(0, _TriangleLightTextureScrollSpeed);
                float2 _SingleLightTextureScrollValue = float2(0, _SingleLightTextureScrollSpeed);

                fixed4 TriangleLightTexColor = fixed4(0, 0, 0, 0);
                fixed4 SingleLightTexColor[7] = {fixed4(0, 0, 0, 0), fixed4(0, 0, 0, 0), fixed4(0, 0, 0, 0),
                                                fixed4(0, 0, 0, 0), fixed4(0, 0, 0, 0), fixed4(0, 0, 0, 0),
                                                fixed4(0, 0, 0, 0)};

                if (_UseLightTex > 0 ) TriangleLightTexColor = tex2D(_TriangleLightTex, i.texcoord2 - _TriangleLightTextureScrollValue);

                if (_UseSingleLightTexture > 0) 
                {
                    SingleLightTexColor[0] = tex2D(_SingleLightTex, i.texcoord3 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[1] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex2 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[2] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex3 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[3] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex4 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[4] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex5 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[5] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex6 - _SingleLightTextureScrollValue);

                    SingleLightTexColor[6] = tex2D(_SingleLightTex, i.texcoord3 + _SingleLightTex7 - _SingleLightTextureScrollValue);
                }

                fixed4 mixedColor[8];

                mixedColor[0] = lerp(col, TriangleLightTexColor, TriangleLightTexColor.a);

                for(int i = 1; i < 8; i++)
                {
                    mixedColor[i] = lerp(col, SingleLightTexColor[i-1], SingleLightTexColor[i-1].a);
                }

                fixed4 finalColor = lerp(mixedColor[0], mixedColor[1], SingleLightTexColor[0].a);

                for(int i = 2; i < 8; i++)
                {
                    finalColor = lerp(finalColor, mixedColor[i], SingleLightTexColor[i-1].a);
                }

                return finalColor;
            }
        ENDCG
    }
}

}