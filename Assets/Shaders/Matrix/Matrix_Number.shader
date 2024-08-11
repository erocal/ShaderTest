Shader "Matrix/Matrix_Number"
{
    Properties
    {
        _MainTex("Image Sequence", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Alpha("Alpha", Range(0, 1)) = 1
        _HorizontalAmount("Horizontal Amount", Float) = 5
        _VerticalAmount("VerticalAmount", Float) = 2
        _CurSequenceId("Current Sequence Id", Int) = 0
        [Toggle(_USETIME)]_UseTime("Use Time to auto Animate", Float) = 0
        _Speed("Speed", Range(1, 30)) = 30
    }
    SubShader
    {
        LOD 200
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        PASS
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma shader_feature_local _USETIME
   
            fixed4 _Color;
            float _Speed;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _CurSequenceId;
            float _Alpha;
            float _ResetTime;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            half2 SequenceFrameAnimation(half2 inputUV, float3 worldPos)
            {

                // 獲取時間，向下取整，以_Speed做調整
                #ifdef _USETIME
                    _CurSequenceId = floor((_Time.y - _ResetTime) * _Speed);
                    _CurSequenceId %= _HorizontalAmount * _VerticalAmount;
                #endif

                _CurSequenceId += 0.1;
				
				//獲取處於哪一行
                float posx = floor(_CurSequenceId % _HorizontalAmount);

                //獲取處於哪一列
                //Unity的紋理座標垂直方向的順序和序列幀紋理中垂直方向上的順序是相反的
                //因此要倒過來取
                float posy = _VerticalAmount - floor(_CurSequenceId / _HorizontalAmount) - 1;
				
				//添加到uv座標上
                half2 uv = inputUV + half2(posx, posy);
                //縮小範圍
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                return uv;

            }

            struct appdata
            {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
                float4 color: COLOR;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv: TEXCOORD1;
                float4 color: COLOR;
            };
   
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld ,v.vertex);
                o.uv = TRANSFORM_TEX(float2(v.texcoord.x, v.texcoord.y + /*floor(*/_Time.y/*)*/), _MainTex);
                o.color = v.color;
                o.color.a = lerp(0, o.color.a, 1 - v.texcoord.y);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                
                fixed4 color = tex2D(_MainTex, SequenceFrameAnimation(i.uv, i.worldPos));
                color.rgb *= _Color.rgb;
                color.a *= (_Alpha * i.color.a);
                return color;

            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

