Shader "Unlit/Dissolve_Simple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gradient("Gradient",2D) = "white" {}
        _ChangeAmount("ChangeAmount",Range(0,1)) = 1
        _EdgeColor("EdgeColor",color) = (0,1,0,1)
        _EdgeWidth("EdgeWidth",Range(0,2)) = 0.2
        _EdgeColorIntensity("EdgeColorIntensity",Range(0,2)) = 1        
        _Spread("Spread主要增加溶解邊緣的對比度，拖尾范圍",Range(0,1)) = 0.3
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

            // 重映射函數
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

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);              
                fixed gradient = tex2D(_Gradient,i.uv1).r;
                float remapData =  remap(_ChangeAmount,0,1.0,-_Spread,1.0);   
                gradient = gradient - remapData;
                //return fixed4((gradient).xxx,1);
                gradient/= _Spread;               
                float dis = saturate(1 - distance(0.5,gradient) / _EdgeWidth);
                //return fixed4((dis).xxx,1);                              
                float alpha =  step(0.5,gradient);
                col.a = alpha * col.a;     
                clip(col.a - 0.5);                                
                // 此處的 col  * _EdgeColor  是去除卡通顏色，讓顏色更加自然
                fixed4 edgeColor = col * _EdgeColor * _EdgeColorIntensity;
                //fixed4 edgeColor =  _EdgeColor * _EdgeColorIntensity;
                col = lerp(col,edgeColor,dis);             
                return col;
            }
            ENDCG
        }
    }
}