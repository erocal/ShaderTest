Shader "Custom/OcclusionShader"
{
    Properties
    {
        // �Q�B�ת�����
        _Color ("Occlusion Color", Color) = (1,1,1,1) // ����B�׮ĪG���C��
        _Width ("Occlusion Width", Range(0,10)) = 1 // ������t���G���e��
        _Intensity("Occlusion Intensity", Range(0, 10)) = 1 // ����G���j��

        // ���Q�B�ת�����
        _Albedo("Albedo", 2D) = "white"{} // ���Ϯg�K��
        _Specular("Specular (RGB-A)", 2D) = "black"{} // �����K�ϡ]�]�ARGB�MAlpha�q�D�^
        _Normal("Nromal", 2D) = "bump"{} // �k�u�K��
        _AO("AO", 2D) = "white"{} // ���ҥ��B�׶K��
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Pass
        {
            ZTest Greater // ������צ�ɷ|���o�ӳq�D
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha // �ϥδ��q���z���V�X�覡

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 worldPos : SV_POSITION;
                float3 viewDir : TEXCOORD0;
                float3 worldNor : TEXCOORD1;
            };

            fixed4 _Color;
            fixed _Width;
            half _Intensity;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.worldPos = UnityObjectToClipPos(v.vertex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.worldNor = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // �p����u�J�g�k�u���I�n�A�ñN��M�g��B�׭�

                // �p��F���u����V�V�q�P���k�u�V�q�������I�n�A�q�L saturate ��ƱN���G����b0��1����
                // �o�˭p���|�o�줤������t�ª��ĪG
                half NDotV = saturate( dot(i.worldNor, i.viewDir));

                // ��1��hNDotV�A�N��F��ϬۮĪG�A�|�ܦ���t�դ�����
                // �ϥ�pow��Ʊ�����t���e�סA���ۭ��H_Intensity������t���G��
                NDotV = pow(1 - NDotV, _Width) * _Intensity;

                fixed4 color;
                color.rgb = _Color.rgb;
                color.a = NDotV; // ��J��z���h�A��{�b�z�ĪG
                return color;
            }
            ENDCG
        }

        CGPROGRAM
        #pragma surface surf StandardSpecular
        #pragma target 3.0

        struct Input
        {
            float2 uv_Albedo;
        };

        sampler2D _Albedo;
        sampler2D _Specular;
        sampler2D _Normal;
        sampler2D _AO;

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            // �q�K�Ϥ����o���Ϯg�C��
            o.Albedo = tex2D(_Albedo, IN.uv_Albedo).rgb;

            // �q�����K�Ϥ����o�����C��M���ƫ�
            fixed4 specular = tex2D(_Specular, IN.uv_Albedo);
            o.Specular = specular.rgb;
            o.Smoothness = specular.a;

            // �q�k�u�K�Ϥ��ѽX�k�u�H��
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Albedo));

            // �q���ҥ��B�׶K�Ϥ����o���ҥ��B�׭�
            o.Occlusion = tex2D(_AO, IN.uv_Albedo).a;
        }
        ENDCG
    }
    Fallback "Diffuse"
}
