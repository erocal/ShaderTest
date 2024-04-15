Shader "Custom/SurfaceSequenceFrameAnimation"
{
    Properties
    {
        _MainTex("Image Sequence", 2D) = "white" {}
        _NormalTex ("Normal Texture", 2D) = "bump" {}
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.0
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Color("Color", Color) = (1, 1, 1, 1)
        _Alpha("Alpha", Range(0, 1)) = 1
        _HorizontalAmount("Horizontal Amount", Float) = 5
        _VerticalAmount("VerticalAmount", Float) = 2
        _CurSequenceId("Current Sequence Id", Int) = 0
        [Toggle]_UseTime("Use Time to auto Animate", Float) = 0
        _Speed("Speed", Range(1, 30)) = 30
    }
    SubShader
    {
        LOD 200
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque"}     
   
        CGPROGRAM
        #pragma surface surf Standard
        
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _UseTime;
        float _Speed;
        float _HorizontalAmount;
        float _VerticalAmount;
        float _CurSequenceId;
        sampler2D _MainTex;
        sampler2D _NormalTex;
        float _Alpha;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 獲取時間，向下取整，以_Speed做調整
            if (_UseTime == 1)
            {
                _CurSequenceId = floor(_Time.y * _Speed);
                _CurSequenceId %= _HorizontalAmount * _VerticalAmount;
            }

            _CurSequenceId += 0.1;
            
            //獲取處於哪一行
            float posx = floor(_CurSequenceId % _HorizontalAmount);

            //獲取處於哪一列
            //Unity的紋理座標垂直方向的順序和序列幀紋理中垂直方向上的順序是相反的
            //因此要倒過來取
            float posy = _VerticalAmount - floor(_CurSequenceId / _HorizontalAmount) - 1;

            //添加到uv座標上
            float2 uv = IN.uv_MainTex + float2(posx, posy);
            //縮小範圍
            uv.x /= _HorizontalAmount;
            uv.y /= _VerticalAmount;

            fixed4 c = tex2D(_MainTex, uv);

            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            o.Alpha = c.a;
            o.Emission = c.rgb * _Color;
            o.Smoothness = _Glossiness * c.a;
            o.Metallic = _Metallic;
            
        }
        ENDCG
    }
    FallBack "Transparent/VertexLit"
}

