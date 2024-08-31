Shader "Unlit/NewUnlitShader"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		Pass
		{
			Blend One One
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
#define hlsl_atan(x,y) atan2(x, y)
#define mod(x,y) ((x)-(y)*floor((x)/(y)))
inline float4 textureLod(sampler2D tex, float2 uv, float lod) {
    return tex2D(tex, uv);
}
inline float2 tofloat2(float x) {
    return float2(x, x);
}
inline float2 tofloat2(float x, float y) {
    return float2(x, y);
}
inline float3 tofloat3(float x) {
    return float3(x, x, x);
}
inline float3 tofloat3(float x, float y, float z) {
    return float3(x, y, z);
}
inline float3 tofloat3(float2 xy, float z) {
    return float3(xy.x, xy.y, z);
}
inline float3 tofloat3(float x, float2 yz) {
    return float3(x, yz.x, yz.y);
}
inline float4 tofloat4(float x, float y, float z, float w) {
    return float4(x, y, z, w);
}
inline float4 tofloat4(float x) {
    return float4(x, x, x, x);
}
inline float4 tofloat4(float x, float3 yzw) {
    return float4(x, yzw.x, yzw.y, yzw.z);
}
inline float4 tofloat4(float2 xy, float2 zw) {
    return float4(xy.x, xy.y, zw.x, zw.y);
}
inline float4 tofloat4(float3 xyz, float w) {
    return float4(xyz.x, xyz.y, xyz.z, w);
}
inline float4 tofloat4(float2 xy, float z, float w) {
    return float4(xy.x, xy.y, z, w);
}
inline float2x2 tofloat2x2(float2 v1, float2 v2) {
    return float2x2(v1.x, v1.y, v2.x, v2.y);
}
// EngineSpecificDefinitions
float rand(float2 x) {
    return frac(cos(mod(dot(x, tofloat2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
float2 rand2(float2 x) {
    return frac(cos(mod(tofloat2(dot(x, tofloat2(13.9898, 8.141)),
						      dot(x, tofloat2(3.4562, 17.398))), tofloat2(3.14))) * 43758.5453);
}
float3 rand3(float2 x) {
    return frac(cos(mod(tofloat3(dot(x, tofloat2(13.9898, 8.141)),
							  dot(x, tofloat2(3.4562, 17.398)),
                              dot(x, tofloat2(13.254, 5.867))), tofloat3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(tofloat2(seed));
}
float3 rgb2hsv(float3 c) {
	float4 K = tofloat4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = c.g < c.b ? tofloat4(c.bg, K.wz) : tofloat4(c.gb, K.xy);
	float4 q = c.r < p.x ? tofloat4(p.xyw, c.r) : tofloat4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return tofloat3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
float3 hsv2rgb(float3 c) {
	float4 K = tofloat4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float smin(float d1, float d2, float k) {
	float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
	return lerp( d2, d1, h ) - k*h*(1.0-h);
}
float smax(float d1, float d2, float k) {
	float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
	return lerp( d2, d1, h ) + k*h*(1.0-h); 
}
float cellular_noise_2d_smooth(float2 coord, float2 size, float offset, float seed, float smoothness) {
	float2 o = floor(coord)+rand2(tofloat2(seed, 1.0-seed))+size;
	float2 f = frac(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			float2 neighbor = tofloat2(float(x),float(y));
			float2 node = rand2(mod(o + tofloat2(x, y), size)) + tofloat2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			float2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = smin(min_dist, dist,clamp(smoothness*0.5,0.0,1.0));
		}
	}
	return min_dist;
}
float fbm_2d_cellular_smooth(float2 coord, float2 size, int folds, int octaves, float persistence, float offset, float seed, float smoothness) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d_smooth(coord*size, size, offset, seed, smoothness);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float2 get_from_tileset(float count, float seed, float2 uv) {
	return clamp((uv+floor(rand2(tofloat2(seed))*count))/count, tofloat2(0.0), tofloat2(1.0));
}
float2 custom_uv_transform(float2 uv, float2 cst_scale, float rnd_rotate, float rnd_scale, float2 seed) {
	seed = rand2(seed);
	uv -= tofloat2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = tofloat2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += tofloat2(0.5);
	return uv;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(frac((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float shape_circle(float2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(float2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = hlsl_atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(float2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = hlsl_atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(frac(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(float2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(hlsl_atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(float2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(hlsl_atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
float3 blend_normal(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
float3 blend_dissolve(float2 uv, float3 c1, float3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
float3 blend_multiply(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
float3 blend_screen(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
float3 blend_overlay(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float3 blend_hard_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
float3 blend_soft_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
float3 blend_burn(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
float3 blend_dodge(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float3 blend_lighten(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
float3 blend_darken(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
float3 blend_difference(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*clamp(c2-c1, tofloat3(0.0), tofloat3(1.0)) + (1.0-opacity)*c2;
}
float3 blend_additive(float2 uv, float3 c1, float3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
float3 blend_addsub(float2 uv, float3 c1, float3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
float3 blend_linear_light(float2 uv, float3 c1, float3 c2, float opacity) {
return opacity*tofloat3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
float3 blend_vivid_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
float3 blend_pin_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_lerp_f(float c1, float c2) {
	return floor(c1 + c2);
}
float3 blend_hard_lerp(float2 uv, float3 c1, float3 c2, float opacity) {
		return opacity*tofloat3(blend_hard_lerp_f(c1.x, c2.x), blend_hard_lerp_f(c1.y, c2.y), blend_hard_lerp_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
float3 blend_exclusion(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float2 transform2_clamp(float2 uv) {
	return clamp(uv, tofloat2(0.0), tofloat2(1.0));
}
float2 transform2(float2 uv, float2 translate, float rotate, float2 scale) {
 	float2 rv;
	uv -= translate;
	uv -= tofloat2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += tofloat2(0.5);
	return rv;	
}
float2 scale(float2 uv, float2 center, float2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
static const float p_o1354876_cx = 0.000000000;
static const float p_o1354876_cy = 0.000000000;
static const float p_o1354876_scale_x = 0.700000000;
static const float p_o1354876_scale_y = 0.700000000;
static const float p_o1354832_amount1 = 1.000000000;
static const float p_o1354830_translate_x = 0.000000000;
static const float p_o1354830_translate_y = 0.000000000;
static const float p_o1354830_rotate = -6.000000000;
static const float p_o1354830_scale_x = 1.180000000;
static const float p_o1354830_scale_y = 1.000000000;
static const float p_o1354827_amount1 = 0.660000000;
static const float p_o1354826_amount1 = 1.110000000;
static const float p_o1354825_d_in1_x = 0.000000000;
static const float p_o1354825_d_in1_y = 0.000000000;
static const float p_o1354825_d_in1_z = 0.000000000;
static const float p_o1354825_d_in2_x = 1.060000000;
static const float p_o1354825_d_in2_y = 0.920000000;
static const float p_o1354825_d_in2_z = 0.650000000;
static const float p_o1354821_default_in1 = 0.000000000;
static const float p_o1354821_default_in2 = 0.000000000;
static const float p_o1354818_default_in1 = 0.000000000;
static const float p_o1354818_default_in2 = 12.680000000;
static const float p_o1354817_default_in1 = 0.000000000;
static const float p_o1354817_default_in2 = 6.000000000;
static const float seed_o1354803 = 0.000000000;
static const float p_o1354803_sx = 1.000000000;
static const float p_o1354803_sy = 1.000000000;
static const float p_o1354803_rotate = 0.000000000;
static const float p_o1354803_scale = 0.000000000;
static const float seed_o1354875 = 0.833631039;
static const float p_o1354875_sx = 16.000000000;
static const float p_o1354875_sy = 16.000000000;
static const float p_o1354875_f = 0.000000000;
static const float p_o1354875_i = 1.000000000;
static const float p_o1354875_p = 1.000000000;
static const float p_o1354875_s = 0.700000000;
float4 o1354803_input_in(float2 uv, float _seed_variation_) {
float o1354875_0_1_f = fbm_2d_cellular_smooth((uv),tofloat2(p_o1354875_sx,p_o1354875_sy),int(p_o1354875_f),int(p_o1354875_i),p_o1354875_p,(_Time.y*.4),(seed_o1354875+frac(_seed_variation_)),p_o1354875_s);
return tofloat4(tofloat3(o1354875_0_1_f), 1.0);
}
static const float p_o1354804_repeat = 1.000000000;
static const float p_o1354804_gradient_0_pos = 0.000000000;
static const float4 p_o1354804_gradient_0_col = tofloat4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
static const float p_o1354804_gradient_1_pos = 1.000000000;
static const float4 p_o1354804_gradient_1_col = tofloat4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
float4 o1354804_gradient_gradient_fct(float x) {
  if (x < p_o1354804_gradient_0_pos) {
    return p_o1354804_gradient_0_col;
  } else if (x < p_o1354804_gradient_1_pos) {
    return lerp(p_o1354804_gradient_0_col, p_o1354804_gradient_1_col, ((x-p_o1354804_gradient_0_pos)/(p_o1354804_gradient_1_pos-p_o1354804_gradient_0_pos)));
  }
  return p_o1354804_gradient_1_col;
}
static const float p_o1354820_default_in1 = 0.000000000;
static const float p_o1354820_default_in2 = 0.000000000;
static const float p_o1354819_sides = 6.000000000;
static const float p_o1354819_radius = 1.470000000;
static const float p_o1354819_edge = 1.000000000;
static const float p_o1354824_d_in1_x = 0.000000000;
static const float p_o1354824_d_in1_y = 0.000000000;
static const float p_o1354824_d_in1_z = 0.000000000;
static const float p_o1354824_d_in2_x = 5.070000000;
static const float p_o1354824_d_in2_y = 1.370000000;
static const float p_o1354824_d_in2_z = 0.760000000;
static const float p_o1354823_default_in1 = 0.000000000;
static const float p_o1354823_default_in2 = 0.000000000;
static const float p_o1354822_sides = 6.000000000;
static const float p_o1354822_radius = 1.000000000;
static const float p_o1354822_edge = 1.020000000;
static const float p_o1354831_translate_x = 0.000000000;
static const float p_o1354831_translate_y = 0.000000000;
static const float p_o1354831_rotate = -3.000000000;
static const float p_o1354831_scale_x = 1.150000000;
static const float p_o1354831_scale_y = 1.000000000;
		
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			fixed4 frag (v2f i) : SV_Target {
				float _seed_variation_ = 0.0;
				float2 uv = i.uv;
float4 o1354804_0_1_rgba = o1354804_gradient_gradient_fct(frac(p_o1354804_repeat*0.15915494309*hlsl_atan((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))).x-0.5)));
float3 o1354803_0_map = ((o1354804_0_1_rgba).rgb);
float o1354803_0_rnd =  float((seed_o1354803+frac(_seed_variation_)))+o1354803_0_map.z;
float4 o1354803_0_1_rgba = o1354803_input_in(get_from_tileset(1.0, o1354803_0_rnd, custom_uv_transform(o1354803_0_map.xy, tofloat2(p_o1354803_sx, p_o1354803_sy), p_o1354803_rotate*0.01745329251, p_o1354803_scale, tofloat2(o1354803_0_map.z, float((seed_o1354803+frac(_seed_variation_)))))), false ? o1354803_0_rnd : 0.0);
float o1354817_0_clamp_false = pow((dot((o1354803_0_1_rgba).rgb, tofloat3(1.0))/3.0),p_o1354817_default_in2);
float o1354817_0_clamp_true = clamp(o1354817_0_clamp_false, 0.0, 1.0);
float o1354817_0_2_f = o1354817_0_clamp_false;
float o1354818_0_clamp_false = o1354817_0_2_f*p_o1354818_default_in2;
float o1354818_0_clamp_true = clamp(o1354818_0_clamp_false, 0.0, 1.0);
float o1354818_0_2_f = o1354818_0_clamp_false;
float o1354819_0_1_f = shape_circle((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))), p_o1354819_sides, p_o1354819_radius*1.0, p_o1354819_edge*1.0);
float o1354820_0_clamp_false = smoothstep(0.0, 1.0, o1354819_0_1_f);
float o1354820_0_clamp_true = clamp(o1354820_0_clamp_false, 0.0, 1.0);
float o1354820_0_1_f = o1354820_0_clamp_false;
float o1354821_0_clamp_false = o1354818_0_2_f*o1354820_0_1_f;
float o1354821_0_clamp_true = clamp(o1354821_0_clamp_false, 0.0, 1.0);
float o1354821_0_1_f = o1354821_0_clamp_false;
float3 o1354825_0_clamp_false = pow(tofloat3(o1354821_0_1_f),tofloat3(p_o1354825_d_in2_x, p_o1354825_d_in2_y, p_o1354825_d_in2_z));
float3 o1354825_0_clamp_true = clamp(o1354825_0_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354825_0_2_rgb = o1354825_0_clamp_false;
float o1354822_0_1_f = shape_circle((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))), p_o1354822_sides, p_o1354822_radius*1.0, p_o1354822_edge*1.0);
float o1354823_0_clamp_false = smoothstep(0.0, 1.0, o1354822_0_1_f);
float o1354823_0_clamp_true = clamp(o1354823_0_clamp_false, 0.0, 1.0);
float o1354823_0_1_f = o1354823_0_clamp_false;
float3 o1354824_0_clamp_false = pow(tofloat3(o1354823_0_1_f),tofloat3(p_o1354824_d_in2_x, p_o1354824_d_in2_y, p_o1354824_d_in2_z));
float3 o1354824_0_clamp_true = clamp(o1354824_0_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354824_0_2_rgb = o1354824_0_clamp_false;
float4 o1354826_0_b = tofloat4(o1354825_0_2_rgb, 1.0);
float4 o1354826_0_l;
float o1354826_0_a;

o1354826_0_l = tofloat4(o1354824_0_2_rgb, 1.0);
o1354826_0_a = p_o1354826_amount1*1.0;
o1354826_0_b = tofloat4(blend_additive((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))), o1354826_0_l.rgb, o1354826_0_b.rgb, o1354826_0_a*o1354826_0_l.a), min(1.0, o1354826_0_b.a+o1354826_0_a*o1354826_0_l.a));

float4 o1354826_0_2_rgba = o1354826_0_b;
float4 o1354827_0_b = o1354826_0_2_rgba;
float4 o1354827_0_l;
float o1354827_0_a;

o1354827_0_l = o1354826_0_2_rgba;
o1354827_0_a = p_o1354827_amount1*1.0;
o1354827_0_b = tofloat4(blend_multiply((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354830_translate_x*(2.0*1.0-1.0), p_o1354830_translate_y*(2.0*1.0-1.0)), p_o1354830_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354830_scale_x*(2.0*1.0-1.0), p_o1354830_scale_y*(2.0*1.0-1.0)))), o1354827_0_l.rgb, o1354827_0_b.rgb, o1354827_0_a*o1354827_0_l.a), min(1.0, o1354827_0_b.a+o1354827_0_a*o1354827_0_l.a));

float4 o1354827_0_2_rgba = o1354827_0_b;
float o1354828_0_1_f = o1354827_0_2_rgba.r;
float4 o1354830_0_1_rgba = tofloat4(tofloat3(o1354828_0_1_f), 1.0);
float4 o1354804_0_3_rgba = o1354804_gradient_gradient_fct(frac(p_o1354804_repeat*0.15915494309*hlsl_atan((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))).y-0.5, (transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))).x-0.5)));
float3 o1354803_2_map = ((o1354804_0_3_rgba).rgb);
float o1354803_2_rnd =  float((seed_o1354803+frac(_seed_variation_)))+o1354803_2_map.z;
float4 o1354803_0_3_rgba = o1354803_input_in(get_from_tileset(1.0, o1354803_2_rnd, custom_uv_transform(o1354803_2_map.xy, tofloat2(p_o1354803_sx, p_o1354803_sy), p_o1354803_rotate*0.01745329251, p_o1354803_scale, tofloat2(o1354803_2_map.z, float((seed_o1354803+frac(_seed_variation_)))))), false ? o1354803_2_rnd : 0.0);
float o1354817_3_clamp_false = pow((dot((o1354803_0_3_rgba).rgb, tofloat3(1.0))/3.0),p_o1354817_default_in2);
float o1354817_3_clamp_true = clamp(o1354817_3_clamp_false, 0.0, 1.0);
float o1354817_0_5_f = o1354817_3_clamp_false;
float o1354818_3_clamp_false = o1354817_0_5_f*p_o1354818_default_in2;
float o1354818_3_clamp_true = clamp(o1354818_3_clamp_false, 0.0, 1.0);
float o1354818_0_5_f = o1354818_3_clamp_false;
float o1354819_0_4_f = shape_circle((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))), p_o1354819_sides, p_o1354819_radius*1.0, p_o1354819_edge*1.0);
float o1354820_2_clamp_false = smoothstep(0.0, 1.0, o1354819_0_4_f);
float o1354820_2_clamp_true = clamp(o1354820_2_clamp_false, 0.0, 1.0);
float o1354820_0_3_f = o1354820_2_clamp_false;
float o1354821_2_clamp_false = o1354818_0_5_f*o1354820_0_3_f;
float o1354821_2_clamp_true = clamp(o1354821_2_clamp_false, 0.0, 1.0);
float o1354821_0_3_f = o1354821_2_clamp_false;
float3 o1354825_3_clamp_false = pow(tofloat3(o1354821_0_3_f),tofloat3(p_o1354825_d_in2_x, p_o1354825_d_in2_y, p_o1354825_d_in2_z));
float3 o1354825_3_clamp_true = clamp(o1354825_3_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354825_0_5_rgb = o1354825_3_clamp_false;
float o1354822_0_4_f = shape_circle((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))), p_o1354822_sides, p_o1354822_radius*1.0, p_o1354822_edge*1.0);
float o1354823_2_clamp_false = smoothstep(0.0, 1.0, o1354822_0_4_f);
float o1354823_2_clamp_true = clamp(o1354823_2_clamp_false, 0.0, 1.0);
float o1354823_0_3_f = o1354823_2_clamp_false;
float3 o1354824_3_clamp_false = pow(tofloat3(o1354823_0_3_f),tofloat3(p_o1354824_d_in2_x, p_o1354824_d_in2_y, p_o1354824_d_in2_z));
float3 o1354824_3_clamp_true = clamp(o1354824_3_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354824_0_5_rgb = o1354824_3_clamp_false;
float4 o1354826_3_b = tofloat4(o1354825_0_5_rgb, 1.0);
float4 o1354826_3_l;
float o1354826_3_a;

o1354826_3_l = tofloat4(o1354824_0_5_rgb, 1.0);
o1354826_3_a = p_o1354826_amount1*1.0;
o1354826_3_b = tofloat4(blend_additive((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))), o1354826_3_l.rgb, o1354826_3_b.rgb, o1354826_3_a*o1354826_3_l.a), min(1.0, o1354826_3_b.a+o1354826_3_a*o1354826_3_l.a));

float4 o1354826_0_5_rgba = o1354826_3_b;
float4 o1354827_3_b = o1354826_0_5_rgba;
float4 o1354827_3_l;
float o1354827_3_a;

o1354827_3_l = o1354826_0_5_rgba;
o1354827_3_a = p_o1354827_amount1*1.0;
o1354827_3_b = tofloat4(blend_multiply((transform2((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), tofloat2(p_o1354831_translate_x*(2.0*1.0-1.0), p_o1354831_translate_y*(2.0*1.0-1.0)), p_o1354831_rotate*0.01745329251*(2.0*1.0-1.0), tofloat2(p_o1354831_scale_x*(2.0*1.0-1.0), p_o1354831_scale_y*(2.0*1.0-1.0)))), o1354827_3_l.rgb, o1354827_3_b.rgb, o1354827_3_a*o1354827_3_l.a), min(1.0, o1354827_3_b.a+o1354827_3_a*o1354827_3_l.a));

float4 o1354827_0_5_rgba = o1354827_3_b;
float o1354828_1_3_f = o1354827_0_5_rgba.g;
float4 o1354831_0_1_rgba = tofloat4(tofloat3(o1354828_1_3_f), 1.0);
float4 o1354804_0_5_rgba = o1354804_gradient_gradient_fct(frac(p_o1354804_repeat*0.15915494309*hlsl_atan((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))).y-0.5, (scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))).x-0.5)));
float3 o1354803_4_map = ((o1354804_0_5_rgba).rgb);
float o1354803_4_rnd =  float((seed_o1354803+frac(_seed_variation_)))+o1354803_4_map.z;
float4 o1354803_0_5_rgba = o1354803_input_in(get_from_tileset(1.0, o1354803_4_rnd, custom_uv_transform(o1354803_4_map.xy, tofloat2(p_o1354803_sx, p_o1354803_sy), p_o1354803_rotate*0.01745329251, p_o1354803_scale, tofloat2(o1354803_4_map.z, float((seed_o1354803+frac(_seed_variation_)))))), false ? o1354803_4_rnd : 0.0);
float o1354817_6_clamp_false = pow((dot((o1354803_0_5_rgba).rgb, tofloat3(1.0))/3.0),p_o1354817_default_in2);
float o1354817_6_clamp_true = clamp(o1354817_6_clamp_false, 0.0, 1.0);
float o1354817_0_8_f = o1354817_6_clamp_false;
float o1354818_6_clamp_false = o1354817_0_8_f*p_o1354818_default_in2;
float o1354818_6_clamp_true = clamp(o1354818_6_clamp_false, 0.0, 1.0);
float o1354818_0_8_f = o1354818_6_clamp_false;
float o1354819_0_7_f = shape_circle((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), p_o1354819_sides, p_o1354819_radius*1.0, p_o1354819_edge*1.0);
float o1354820_4_clamp_false = smoothstep(0.0, 1.0, o1354819_0_7_f);
float o1354820_4_clamp_true = clamp(o1354820_4_clamp_false, 0.0, 1.0);
float o1354820_0_5_f = o1354820_4_clamp_false;
float o1354821_4_clamp_false = o1354818_0_8_f*o1354820_0_5_f;
float o1354821_4_clamp_true = clamp(o1354821_4_clamp_false, 0.0, 1.0);
float o1354821_0_5_f = o1354821_4_clamp_false;
float3 o1354825_6_clamp_false = pow(tofloat3(o1354821_0_5_f),tofloat3(p_o1354825_d_in2_x, p_o1354825_d_in2_y, p_o1354825_d_in2_z));
float3 o1354825_6_clamp_true = clamp(o1354825_6_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354825_0_8_rgb = o1354825_6_clamp_false;
float o1354822_0_7_f = shape_circle((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), p_o1354822_sides, p_o1354822_radius*1.0, p_o1354822_edge*1.0);
float o1354823_4_clamp_false = smoothstep(0.0, 1.0, o1354822_0_7_f);
float o1354823_4_clamp_true = clamp(o1354823_4_clamp_false, 0.0, 1.0);
float o1354823_0_5_f = o1354823_4_clamp_false;
float3 o1354824_6_clamp_false = pow(tofloat3(o1354823_0_5_f),tofloat3(p_o1354824_d_in2_x, p_o1354824_d_in2_y, p_o1354824_d_in2_z));
float3 o1354824_6_clamp_true = clamp(o1354824_6_clamp_false, tofloat3(0.0), tofloat3(1.0));
float3 o1354824_0_8_rgb = o1354824_6_clamp_false;
float4 o1354826_6_b = tofloat4(o1354825_0_8_rgb, 1.0);
float4 o1354826_6_l;
float o1354826_6_a;

o1354826_6_l = tofloat4(o1354824_0_8_rgb, 1.0);
o1354826_6_a = p_o1354826_amount1*1.0;
o1354826_6_b = tofloat4(blend_additive((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), o1354826_6_l.rgb, o1354826_6_b.rgb, o1354826_6_a*o1354826_6_l.a), min(1.0, o1354826_6_b.a+o1354826_6_a*o1354826_6_l.a));

float4 o1354826_0_8_rgba = o1354826_6_b;
float4 o1354827_6_b = o1354826_0_8_rgba;
float4 o1354827_6_l;
float o1354827_6_a;

o1354827_6_l = o1354826_0_8_rgba;
o1354827_6_a = p_o1354827_amount1*1.0;
o1354827_6_b = tofloat4(blend_multiply((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), o1354827_6_l.rgb, o1354827_6_b.rgb, o1354827_6_a*o1354827_6_l.a), min(1.0, o1354827_6_b.a+o1354827_6_a*o1354827_6_l.a));

float4 o1354827_0_8_rgba = o1354827_6_b;
float o1354828_2_5_f = o1354827_0_8_rgba.b;
float4 o1354829_0_1_rgba = tofloat4((dot((o1354830_0_1_rgba).rgb, tofloat3(1.0))/3.0), (dot((o1354831_0_1_rgba).rgb, tofloat3(1.0))/3.0), o1354828_2_5_f, 1.0);
float4 o1354832_0_b = o1354829_0_1_rgba;
float4 o1354832_0_l;
float o1354832_0_a;

o1354832_0_l = o1354829_0_1_rgba;
o1354832_0_a = p_o1354832_amount1*1.0;
o1354832_0_b = tofloat4(blend_additive((scale((uv), tofloat2(0.5+p_o1354876_cx, 0.5+p_o1354876_cy), tofloat2(p_o1354876_scale_x, p_o1354876_scale_y))), o1354832_0_l.rgb, o1354832_0_b.rgb, o1354832_0_a*o1354832_0_l.a), min(1.0, o1354832_0_b.a+o1354832_0_a*o1354832_0_l.a));

float4 o1354832_0_2_rgba = o1354832_0_b;
float3 o1354833_0_1_rgb = tanh(((o1354832_0_2_rgba).rgb));
float4 o1354876_0_1_rgba = tofloat4(o1354833_0_1_rgb, 1.0);

				// sample the generated texture
				fixed4 col = o1354876_0_1_rgba;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}



