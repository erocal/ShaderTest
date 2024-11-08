Shader "Outline/Outline_Stencil"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0, 50)) = 2
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType" = "Geometry" }
        LOD 100
        Stencil {
                Ref 0          //0-255
                Comp Equal     //default:always
                Pass IncrSat   //default:keep
                Fail keep      //default:keep
                ZFail keep     //default:keep
        }

        Pass
        {
            
            Name "Mask"
            Cull Off
            ZTest Always
            ZWrite Off
            ColorMask 0
            
        }

        Pass
        {

            Name "Fill"
            Cull Off
            ZTest LEqual
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 smoothNormal : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 position : SV_POSITION;
                fixed4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _OutlineColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _OutlineWidth)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(appdata input) {
                v2f output;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 normal = any(input.smoothNormal) ? input.smoothNormal : input.normal;
                float3 viewPosition = UnityObjectToViewPos(input.vertex);
                float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal));

                output.position = UnityViewToClipPos(viewPosition + viewNormal * -viewPosition.z * UNITY_ACCESS_INSTANCED_PROP(Props, _OutlineWidth) / 1000.0);
                output.color = UNITY_ACCESS_INSTANCED_PROP(Props, _OutlineColor);

                return output;
            }

            fixed4 frag(v2f input) : SV_Target {

                UNITY_SETUP_INSTANCE_ID(input);

                return input.color;

            }
            ENDCG
        }
    }
}