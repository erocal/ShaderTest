Shader "Holistic/DotProduct"
{
    Properties
    {
        _DotColor ("Dot Color", Color) = (0, 1, 1, 1)
        _DotLimit ("Dot Limit", Range(-1, 1)) = .3
    }
    SubShader
    {

        CGPROGRAM
        #pragma surface surf Lambert

        float4 _DotColor;
        float _DotLimit;

        struct Input
        {
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            /// 計算的是視角方向向量和表面法線向量之間的點積
            /// 這個值可以用來判斷視角方向與表面法線的相對方向
            /// 當點積值為1時，兩個向量是完全平行且方向一致
            /// 當點積值為-1時，兩個向量是完全平行但方向相反
            /// 當點積值為0時，兩個向量是垂直的
            half dotp = dot(IN.viewDir, o.Normal);

            if (dotp < _DotLimit) o.Albedo = _DotColor.rgb;
            else o.Albedo = float3(1, 1, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
