/// 轉換矩陣 https://openhome.cc/Gossip/WebGL/images/TransformationMatrix-3.JPG

Shader "USB/USB_function_SINCOS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(XAxis, YAxis, ZAxis)] _Axis ("Axis", Float) = 0
        _Speed ("Rotation Speed", Range(0, 3)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature_local _AXIS_XAXIS _AXIS_YAXIS _AXIS_ZAXIS

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            
            // let's add our rotation X-axis function
            float3 rotationXaxis(float3 vertex)
            {

                // let’s add the rotation X-axis variables
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);

                // create a three-dimensional matrix
                float3x3 m = float3x3
                (
                    1, 0, 0,
                    0, c, -s,
                    0, s, c
                );
                // let’s multiply the matrix times the vertex input
                return mul(m, vertex);
            }

            // let's add our rotation Y-axis function
            float3 rotationYaxis(float3 vertex)
            {

                // let’s add the rotation Y-axis variables
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);

                // create a three-dimensional matrix
                float3x3 m = float3x3
                (
                    c, 0, s,
                    0, 1, 0,
                    -s, 0, c
                );
                // let’s multiply the matrix times the vertex input
                return mul(m, vertex);
            }

            // let's add our rotation Z-axis function
            float3 rotationZaxis(float3 vertex)
            {

                // let’s add the rotation Z-axis variables
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);

                // create a three-dimensional matrix
                float3x3 m = float3x3
                (
                    c, -s, 0,
                    s, c, 0,
                    0, 0, 1
                );
                // let’s multiply the matrix times the vertex input
                return mul(m, vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                #if defined(_AXIS_XAXIS)
                    float3 rotVertex = rotationXaxis(v.vertex);
                #elif defined(_AXIS_YAXIS)
                    float3 rotVertex = rotationYaxis(v.vertex);
                #elif defined(_AXIS_ZAXIS)
                    float3 rotVertex = rotationZaxis(v.vertex);
                #endif
                o.vertex = UnityObjectToClipPos(rotVertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = tex2D(_MainTex, i.uv);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;

            }
            
            ENDCG
        }
    }
}