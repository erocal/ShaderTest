#ifndef DEGREE_2_RADIAN
#define DEGREE_2_RADIAN 0.01745329252
#endif

inline float2 rotateUV (fixed2 uv, float rotation)
{
    float sinX = sin (rotation);
    float cosX = cos (rotation);
    float2x2 rotationMatrix = float2x2( cosX, -sinX, sinX, cosX);
    return mul (uv - fixed2 (0.5, 0.5), rotationMatrix) + fixed2 (0.5, 0.5);
}