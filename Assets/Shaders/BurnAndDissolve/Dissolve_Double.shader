Shader "Custom/Unlit/Dissolve_Double"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gradient("Gradient",2D) = "white" {}
        _ChangeAmount("ChangeAmount",Range(0,1)) = 1
        _EdgeColor("EdgeColor已经被弃用，改为从 Ramp图中采样颜色",color) = (0,1,0,1)
        _EdgeWidth("EdgeWidth",Range(0,2)) = 0.2
        _EdgeColorIntensity("EdgeColorIntensity",Range(0,2)) = 1        
        _Spread("Spread溶解边缘的扩散值",Range(0,1)) = 0.3
        
        _Noise("Noise Tex",2D) = "white"{}
        
        _Ramp("Ramp Tex",2D) = "white"{}
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            };
            float _ChangeAmount;
            sampler2D _MainTex,_Gradient;
            float4 _MainTex_ST,_Gradient_ST;

            float4 _EdgeColor;
            float _EdgeWidth,_EdgeColorIntensity;
            float _Spread;
            
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
                o.uv1 = TRANSFORM_TEX(v.uv, _Gradient);
                return o;
            }

            // 思路并不复杂，重要的是思路！！！！！
            //  step,  lerp， smoothStep 组合  0，1 相乘，  然后裁剪屏蔽 只留下白色1，黑色0
            // 这样就能够在特定的位置产生相应的效果
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);              
                fixed gradient = tex2D(_Gradient,i.uv1).r;
                float remapData =  remap(_ChangeAmount,0,1.0,-_Spread,1.0);   
                gradient = gradient - remapData;
                //return fixed4((gradient).xxx,1);
                gradient/= _Spread;
                
                //方向控制
                float noise = tex2D(_Noise,i.uv).r;
                // 乘以2 - noise  是为了确保   当 溶解未开始的情况下 保证未溶解   
                gradient = gradient* 2 - noise;      
                      
                      
                      
                      
                        
                
                float dis = saturate(1 - distance(0.5,gradient) / _EdgeWidth);
                
                //  渐变色-----------
                float2 rampUV = float2(1 - dis,0.5 );
                float4 edgeCol = tex2D(_Ramp,rampUV);              
                
                //----------------  
                //return fixed4((dis).xxx,1);                              
                float alpha =  step(0.5,gradient);
                col.a = alpha * col.a;     
                clip( col.a - 0.5);                                
                fixed4 edgeColor = edgeCol * _EdgeColorIntensity;
                col = lerp(col,edgeColor,dis);             
                return col;
            }
            ENDCG
        }
    }
}