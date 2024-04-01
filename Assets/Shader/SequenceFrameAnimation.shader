Shader "Custom/SequenceFrameAnimation"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        [PerRendererData]_MainTex("Image Sequence", 2D) = "white" {}
        _HorizontalAmount("Horizontal Amount", Float) = 2
        _VerticalAmount("VerticalAmount", Float) = 2
        _Speed("Speed", Range(1, 10)) = 30
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
   
            fixed4 _Color;
            float _Speed;
            float _HorizontalAmount;
            float _VerticalAmount;
            sampler2D _MainTex;

            float4 _MainTex_ST;
            struct appdata
            {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
            };
            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };
   
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
            	// 獲取時間，向下取整，以_Speed做調整
                float time = floor(_Time.y * _Speed);

                //獲取當前圖片ID
                float curSequenceId = time % (_HorizontalAmount * _VerticalAmount);
				
				//水平方向取模，获取行的索引号
                float posx = floor(curSequenceId % _HorizontalAmount);
                //floor(curSequenceId / _HorizontalAmount)能获得纹理坐标竖直方向的序列数
                //Unity的纹理坐标竖直方向的顺序和序列帧纹理中竖直方向上的顺序是相反的。
                //用总体-1-纹理坐标序列数得到序列帧纹理中竖直方向索引号
                float posy = _VerticalAmount - floor(curSequenceId / _HorizontalAmount) - 1;
				
				//添加到uv坐标上
                half2 uv = i.uv + half2(posx, posy);
                //缩小范围
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;
                fixed4 color = tex2D(_MainTex, uv);
                //添加颜色
                color.rgb *= _Color;
                return color;

            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
