Shader "Unlit/ScoreBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Overlay" }
        LOD 100

        Lighting Off
        ZTest Always

        CGPROGRAM
        #pragma surface surf NoLighting noforwardadd

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
    	    fixed4 c;
    	    c.rgb = s.Albedo; 
    	    c.a = s.Alpha;
    	    return c;
        }

        sampler2D _MainTex;
        fixed4 _MainColor;

        struct Input
        {
            float2 uv_MainTex;
        };
            
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

            c *= _MainColor;

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
}