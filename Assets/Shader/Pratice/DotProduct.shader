Shader "Holistic/DotProduct"
{
    SubShader
    {

        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half dotp = dot(IN.viewDir, o.Normal);

            if (dotp < 0.3) o.Albedo = float3(dotp, 1, 1);
            else o.Albedo = float3(1, 1, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
