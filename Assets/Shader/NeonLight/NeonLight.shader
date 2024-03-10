Shader "Unlit/NeonLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color",color) = (1,1,1,1)
        _LightTex ("LightTexture", 2D) = "white" {}
        _LightTex2 ("LightTexture2", 2D) = "white" {}
        _Speed("Scroll Speed",Range(-4,4))=1
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
        sampler2D _LightTex2;
        fixed4 _MainColor;
        fixed _Speed;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_LightTex;
            float2 uv3_LightTex2;
        };
            
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

            fixed2 scrollValue = fixed2(0,_Speed) * _Time;

            fixed4 lightTexColor = tex2D(_LightTex, IN.uv2_LightTex + scrollValue);

            fixed4 lightTex2Color = tex2D(_LightTex2, IN.uv3_LightTex2 + scrollValue);

            fixed4 mixedColor1 = lerp(c, lightTexColor, lightTexColor.a);
            fixed4 mixedColor2 = lerp(c, lightTex2Color, lightTex2Color.a);

            fixed4 finalColor = lerp(mixedColor1, mixedColor2, lightTex2Color.a);

            o.Albedo = finalColor.rgb;
            o.Alpha = finalColor.a;
        }
        ENDCG
    }
}