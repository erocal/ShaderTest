Shader "Custom/Unlit/SkyboxReflection"
{
    Properties
    {
        _CubeMap ("CubeMap", Cube) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members position)
#pragma exclude_renderers d3d11
        
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            samplerCUBE _CubeMap;
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 reflectPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNromal(v.normal);
                float3 ViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.reflectPos = reflect(-ViewDir, o.worldNormal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return texCUBE(_CubeMap, i.reflectPos);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
