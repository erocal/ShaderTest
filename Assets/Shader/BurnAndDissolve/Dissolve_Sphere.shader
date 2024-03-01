Shader "Custom/Unlit/Dissolve_Sphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ChangeAmount("ChangeAmount",Range(0,1)) = 1
        _EdgeColor("EdgeColor已经被弃用，改为从 Ramp图中采样颜色",color) = (0,1,0,1)
        _EdgeWidth("EdgeWidth",Range(0,2)) = 0.2
        _EdgeColorIntensity("EdgeColorIntensity",Range(0,2)) = 1        
        _Spread("Spread溶解边缘的扩散值",Range(0,1)) = 0.3
        
        _Noise("Noise Tex",2D) = "white"{}
        
        _Ramp("Ramp Tex",2D) = "white"{}
        _Softness("Softness",Range(0,0.5)) = 0.3
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            cull off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
            };
            float _ChangeAmount;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _EdgeColor;
            float _EdgeWidth,_EdgeColorIntensity;
            float _Spread,_Softness;
            
            sampler2D _Noise;
            sampler2D _Ramp;

            // 重映射函数
            float remap(float x,float oldmin,float oldMax,float newMin,float newMax)
            {
                return (x - oldmin)/(oldMax - oldmin) * (newMax-newMin) + newMin;   
            }          


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 rootPos = mul(unity_ObjectToWorld,float4(-0.5,-0.5,-0.5,1));
                //float3 rootPos = mul(unity_ObjectToWorld,float4(0,0,0,1));
                // 球形溶解
                float gradient = distance(i.worldPos,rootPos) / 1.8;
                // 垂直方向溶解
                //float gradient = i.worldPos.y - rootPos.y;                         
                fixed4 col = tex2D(_MainTex, i.uv);              
                float remapData =  remap(_ChangeAmount,0,1.0,-_Spread,1.0);   
                gradient = gradient - remapData;
                gradient/= _Spread;
                
                //方向控制
                float noise = tex2D(_Noise,i.uv).r;
                // 乘以2 - noise  是为了确保   当 溶解未开始的情况下 保证未溶解   
                gradient = gradient* 2 - noise;                                          
                float dis = saturate(1 - distance(_Softness,gradient) / _EdgeWidth);
                
                //  渐变色-----------
                float2 rampUV = float2(1 - dis,0.5 );
                float4 edgeCol = tex2D(_Ramp,rampUV);              
               
               
               
                float alpha =  smoothstep(_Softness,0.5,gradient);       
                fixed4 edgeColor = edgeCol * _EdgeColorIntensity;
                float3 emission = lerp(col,edgeColor,dis).rgb;
                col.a = alpha * col.a;
                return float4(emission,col.a);
            }
            ENDCG
        }
    }
}
