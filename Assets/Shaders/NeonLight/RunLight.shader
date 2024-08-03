Shader "Unlit/RunLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color",color) = (1,1,1,1)
        _LightTex ("LightTexture", 2D) = "white" {}
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
        sampler2D _LightTex;
        fixed4 _MainColor;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_LightTex;
        };
            
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

            fixed4 lightTexColor = tex2D(_LightTex, IN.uv2_LightTex);

            //c *= _MainColor;
            lightTexColor.rgb = lerp(c.rgb, lightTexColor.rgb, lightTexColor.a);


            o.Albedo = lightTexColor.rgb;
            o.Alpha = lightTexColor.a;
        }
        ENDCG
    }
}