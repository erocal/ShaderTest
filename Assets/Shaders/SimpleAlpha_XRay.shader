﻿Shader "Unlit/SimpleAlpha_XRay"
{
    Properties
    {
        [HDR]_XRayCol ("XRay Color", Color) = (1, 1, 1, 1)
        _XRayFresPow ("XRay Fresnel Pow", Float) = 5
    }
    SubShader
    {        
        //lighting pass
        //深度測試通過的地方用普通光著色
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            Stencil 
            {
                Ref 1
                Comp GEqual //该ref值(1)比缓冲中的值大于等于时通过
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };
        
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 wNor : TEXCOORD1;
            };
        
            float _Alpha;
        
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.wNor = UnityObjectToWorldNormal(v.normal);
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float LdN = dot(lDir, i.wNor);
                fixed4 col = 1;
                col.xyz = LdN * 0.5 + 0.5;//用简单的半兰伯特光照模型
                return col;
            }
            ENDCG
        }

        //x ray pass
        //深度測試未通過的地方用透視著色
        Pass
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
            ZTest Greater

            Stencil 
            {
                Ref 0
                Comp Equal
                Pass Keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 wNor : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            float4 _XRayCol;
            float _XRayFresPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.wNor = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                float fres = dot(vDir, i.wNor);
                fres = pow(1 - fres, _XRayFresPow);
                fixed4 col = fres * _XRayCol;
                col.a = saturate(col.a);
                return col;
            }
            ENDCG
        }
    }
}
