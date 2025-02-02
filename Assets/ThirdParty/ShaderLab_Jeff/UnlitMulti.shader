Shader "Unlit/UnlitMulti"
{
    Properties
    {
        _Value ("Value", float) = 1.0
        _MainTex( "Texture" , 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert ( MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
               return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }
}
