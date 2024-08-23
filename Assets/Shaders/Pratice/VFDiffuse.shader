Shader "Holistic/VFDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets\Cginc\VFDiffuse.cginc"
            
            ENDCG
        }
    }
}
