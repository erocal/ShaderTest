// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

Shader "ToonShader/Instancing_ToonShader"
{
    Properties
    {
        _BaseColor        ( "主貼圖" , 2D ) = "white" {}
        _Color            ( "顏色" , Color ) = ( 1,1,1,1 )
        _Shadowcolor      ( "影子顏色" , Color ) = ( 0,0,0,0 )
        _Gloss            ( "高光強度" , Range(0,1) ) = 0
        [NoScaleOffset] _GlossMask        ( "高光遮罩" , 2D ) = "gray" {}
        [NoScaleOffset] _Normalmap        ( "法線貼圖" , 2D ) = "bump" {}
        _NormalIntensity  ( "法線強度" , Range(0,1) ) = 0
        _OutlineColor     ( "邊線顏色" , Color ) = (0,0,0,0)
        _OutlineWidth     ( "邊線粗度" , Range(0,1) ) = 0.5
    }
    SubShader
    {
        Tags{"RenderType"="Transparent"  "Queue"="Geometry"}
        //Base Pass    
        Pass
            {
            Tags{"LightMode" = "ForwardBase"}
            
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_instancing
                #pragma instancing_options assumeuniformscaling // 物體具有相同比例
                #define IS_IN_BASE_PASS
                #pragma multi_compile_fwdbase
                #include "Instancing_IncToon.cginc"
            ENDCG 
            } 

        //Add Pass    
        Pass
            {
            Tags{"LightMode" = "ForwardAdd"}

            Blend SrcAlpha One
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_instancing
                #pragma instancing_options assumeuniformscaling // 物體具有相同比例
                #define IS_IN_Add_PASS
                #pragma multi_compile_fwdadd
                #include "Instancing_IncToon.cginc"
            ENDCG
            }
        
        //計算影子        
        Pass
            {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_instancing
                #pragma instancing_options assumeuniformscaling // 物體具有相同比例
                #define USE_LIGHTING
                #pragma multi_compile_shadowcaster
                #include "UnityCG.cginc"


                struct Interpolators 
                {
                    V2F_SHADOW_CASTER;
                    UNITY_VERTEX_OUTPUT_STEREO
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                Interpolators vert(appdata_base v)
                {
                    Interpolators o;

                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);

				    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                    return o;
                }

                float4 frag(Interpolators i) : SV_Target
                {

                    UNITY_SETUP_INSTANCE_ID(i);

                    SHADOW_CASTER_FRAGMENT(i);
                }
            ENDCG
            } 
        //邊線
        Pass
            {
            Cull Front
            CGPROGRAM
                
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_instancing
                #pragma instancing_options assumeuniformscaling // 物體具有相同比例

                #include "UnityCG.cginc"
                
                fixed4  _OutlineColor;
                half   _OutlineWidth;

                struct  MeshData
                {
                    half4 vertex : POSITION;
                    half3 normals : NORMAL;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct  Interpolators
                {
                    half4 vertex : SV_POSITION;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                Interpolators vert ( MeshData v )
                {
                    Interpolators o;

                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);

                    v.vertex.xyz    += v.normals *_OutlineWidth/5;
                    o.vertex            = UnityObjectToClipPos(v.vertex);
                    return o;
                }
                
                fixed4 frag ( Interpolators i ) : COLOR
                {

                    UNITY_SETUP_INSTANCE_ID(i);

                    return fixed4 ( _OutlineColor.rgb , 0);
                }
            ENDCG
            }
     

    }
}