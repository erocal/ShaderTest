Shader "Custom/HorizontalMarquee"
{
    Properties
{
    [PerRendererData]_MainTex ("Albedo (RGB)", 2D) = "white" {}
    _HSVRangeMin ("HSV Affect Range Min", Range(0, 1)) = 0
   _HSVRangeMax ("HSV Affect Range Max", Range(0, 1)) = 1
   _HSVAAdjust ("HSVA Adjust", Vector) = (0, 1, 0, 0)
    _Speed ("Speed", Range(0, 30)) = 25
    _ColorSpeed ("Color Speed", Range(0, 30)) = 2.4
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
   
        sampler2D _MainTex;
        float _HSVRangeMin;
        float _HSVRangeMax;
        float4 _HSVAAdjust;
        float _Speed;
        float _ColorSpeed;

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
            o.uv.x += _Time * _Speed;
            return o;
        }

        float3 rgb2hsv(float3 c) {
          float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
          float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
          float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

          float d = q.x - min(q.w, q.y);
          float e = 1.0e-10;
          return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
        }

        float3 hsv2rgb(float3 c) {
          c = float3(c.x, clamp(c.yz, 0.0, 1.0));
          float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
          float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
          return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }

        fixed4 frag(v2f i) : SV_Target
        {

            fixed4 texColor = tex2D(_MainTex, i.uv);
            
            _HSVAAdjust.x += _Time.y;

            float3 hsv = rgb2hsv(texColor.rgb);
            float affectMult = step(_HSVRangeMin, hsv.r) * step(hsv.r, _HSVRangeMax);
            float3 rgb = hsv2rgb(hsv + _HSVAAdjust.xyz * affectMult);

            

            //texColor.rgb *= frac(_Time * _ColorSpeed);
            //return texColor;

            return texColor*float4(rgb, 1);

        }
        ENDCG
    }
}
FallBack "Diffuse"
}
