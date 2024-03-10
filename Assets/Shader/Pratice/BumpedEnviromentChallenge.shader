Shader "Holistic/BumpedEnviromentChallenge"
{
    Properties {
        _myBump ("Bump Texture", 2D) = "bump" {}
        _mySlider ("Bump Amount", Range(0,10)) = 1
        _myTextureBumpSlider ("Texture Bump Amount", Range(0,2)) = 1
        _myCube ("Cube Map", Cube) = "white" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myBump;
        half _mySlider;
        half _myTextureBumpSlider;
        samplerCUBE _myCube;

        struct Input {
            float2 uv_myBump;
            float3 worldRefl; INTERNAL_DATA
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = texCUBE(_myCube, WorldReflectionVector (IN, o.Normal)).rgb;
            o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump) * 0.3); // 將Bump Texture的rgb轉換為法線貼圖的xyz
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }
