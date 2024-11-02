// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

        struct MeshData
        {
            UNITY_VERTEX_INPUT_INSTANCE_ID
            float4 vertex : POSITION;
            float4 normals : NORMAL;
            float4 tangent : TANGENT;  //float4 (x,y,z,w)
            float2 uv0 : TEXCOORD0;
        };

        struct Interpolators
        {
            UNITY_VERTEX_INPUT_INSTANCE_ID
            float4 pos      : SV_POSITION;
            float3 normal   : NORMAL;
            float3 tangent  : TEXCOORD0;
            float3 bitangent: TEXCOORD1;
            float2 uv       : TEXCOORD2;
            float3 wpos     : TEXCOORD3;
        #ifdef IS_IN_BASE_PASS
            SHADOW_COORDS(4)
        #elif defined (IS_IN_Add_PASS)
            LIGHTING_COORDS(5,6)
        #endif
        UNITY_FOG_COORDS(7)
        };

sampler2D _BaseColor;
sampler2D _Normalmap;
sampler2D _GlossMask;
float4  _BaseColor_ST;
float4  _RimColor;
float3  _Shadowcolor;
float   _Gloss;
float   _RimIntensity;
float   _NormalIntensity;

UNITY_INSTANCING_BUFFER_START(InstanceProperties)
	UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_INSTANCING_BUFFER_END(InstanceProperties)

        Interpolators vert ( MeshData v)
        {
            Interpolators o;

            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_TRANSFER_INSTANCE_ID(v, o);

            o.uv         = TRANSFORM_TEX( v.uv0 , _BaseColor );
            o.normal     = UnityObjectToWorldNormal(v.normals);
            o.tangent    = UnityObjectToWorldDir(v.tangent.xyz);
            o.bitangent  = cross( o.normal , o.tangent );
            o.bitangent *= v.tangent.w * unity_WorldTransformParams.w ;
            o.pos        = UnityObjectToClipPos(v.vertex);
            o.wpos   = mul( unity_ObjectToWorld , v.vertex );
            UNITY_TRANSFER_FOG(o,o.vertex);

        #ifdef IS_IN_BASE_PASS
            TRANSFER_SHADOW(o);
        #elif defined (IS_IN_Add_PASS)
            TRANSFER_VERTEX_TO_FRAGMENT(o);                                            
        #endif
            
            return o;

        }

        float4 frag (Interpolators i) : SV_Target
        {

            UNITY_SETUP_INSTANCE_ID(i);

        //貼圖顏色
            float4 basecolor  = tex2D( _BaseColor , i.uv ); 
                   basecolor *= UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _Color) ;     
        //NORMAL
            float3 normalmap  = UnpackNormal(tex2D( _Normalmap , i.uv ));
                   normalmap  = normalize( lerp ( float3(0,0,1), normalmap, _NormalIntensity)); 
            float3x3 mtxTangentToWorld =
            {
                i.tangent.x, i.bitangent.x, i.normal.x,
                i.tangent.y, i.bitangent.y, i.normal.y,
                i.tangent.z, i.bitangent.z, i.normal.z
            };  

            float3  N       = mul( mtxTangentToWorld , normalmap );
            

    #ifdef USE_LIGHTING
        //處理影子&光 
            float   attenuation  = LIGHT_ATTENUATION (i);
            float3  L            = normalize(UnityWorldSpaceLightDir(i.wpos)); // 平行光
            float3  V            = normalize(_WorldSpaceCameraPos - (i.wpos));//玩家視角
            float3  lambert      = saturate(dot( N , L )) ;
                    lambert     *= attenuation;
            float   SDsmooth     = saturate(smoothstep( 0 , 0.1 , lambert ));//影子邊緣的模糊度 
            float3  SDType       = lerp( _Shadowcolor , float3( 1 , 1 , 1 ) , SDsmooth );
            float3  lightandshadow = SDType * _LightColor0;
            
        //Specular
            float3  glossmask      = tex2D( _GlossMask , i.uv );
            float   Glossexp       = exp2 ( _Gloss * 10 ) + 2;
            float3  BlinnPhong     = normalize( L + V );
            float3  specularlight  = saturate(dot( N , BlinnPhong )) * ( lambert > 0 );
                    specularlight  = pow( specularlight , Glossexp ) * _Gloss * attenuation;
                    specularlight *= _LightColor0.xyz;

            UNITY_APPLY_FOG( i.fogCoord, basecolor );        
    
            return  float4( lightandshadow * basecolor.rgb + specularlight * glossmask , basecolor.a ) ;
    #else
        #ifdef IS_IN_BASE_PASS
            return 0;
        #else
            return 0;
        #endif
    #endif
}