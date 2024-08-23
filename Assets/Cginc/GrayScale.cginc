#include "UnityCG.cginc"

float4 GrayScale(float4 color)
{

    // 加權平均法 灰度變化
    fixed gray = dot(color.rgb, fixed3(.299, .587, .114));
    return half4(gray, gray, gray, color.a);

}