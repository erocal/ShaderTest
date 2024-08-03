Shader "Unlit/WormHole"
{
    Properties
    {
        
        _MainTex ("Texture", 2D) = "white" {}
        _Value ( " Value " , Range( 0,10 ) ) = 1
        [IntRange] _Amount ( "_Amount" , Range( 0,10 ) ) = 1
        _Speed ( "_Speed" , Range( 0,10 ) ) = 0
        _Strength ( "_Strength" , Range( -50,5 ) ) = 2
        _Test( "_Test", Vector) = (0, 0, 0, 0)
        _DistanceFactor ( "_DistanceFactor" , Range( -2,2 ) ) = 2
        _Progress ( "_Progress" , Float) = 1
    
    }
    SubShader
    {
        Tags 
        { 
            " RenderType " = " Opaque "
            " Queue " = " Geometry "
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Value;               
            float _Amount;              //波的數量
            float _Speed;               //波的速度
            float _Strength;            //波的強度
            float _FragVertexZ;
            vector _Test;
            float _DistanceFactor;
            float _Progress;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD1;
                float2 uv_MainTex : TEXCOORD2;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 uv_MainTex : TEXCOORD2;
            };

            //方法
            float GetWave ( float2 inputuv )
            {
                float2 center = inputuv * 2 - 1 ;
                float radialDistance = length ( center ) ;
                float wave = cos ( radialDistance * TAU * _Amount /*- ( _Time.y * _Speed )*/ ) * .5 + .5 ;
                wave *= 1 - radialDistance ;
                return wave;
            }

            float2 CenterExpand ( float2 inputuv )
            {
                float2 newUV = inputuv - float2(.5, .5);
                float2 norNewUV = normalize ( newUV);
                float2 offset = norNewUV * (frac(_DistanceFactor - _Time.y * .002 )*10* _Speed - 6);
                newUV = offset + inputuv;
                return newUV;
            }

            // 塌陷
            float2 CenterProgress ( float2 inputuv )
            {
                float2 newUV = inputuv - float2(.5f, .5f);
                
                float dis = length(newUV);

                newUV = inputuv + normalize(newUV) * (1 - length(inputuv)) * _Progress;

                return newUV;
            }

            Interpolators vert ( MeshData v)
            {
                Interpolators o;

                v.vertex.y = GetWave(v.uv0) * _Strength ;  //最終輸出 v.vertex.y
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                o.uv_MainTex = TRANSFORM_TEX(v.uv_MainTex, _MainTex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float time = _Time.y*_Speed;
                float2 uv_MainTex = float2(i.uv_MainTex.x + _Test.x*time, i.uv_MainTex.y + _Test.y*time);

                return GetWave(i.uv) * tex2D(_MainTex, CenterExpand( i.uv_MainTex ));          
            }

            ENDCG
        }
    }
}
