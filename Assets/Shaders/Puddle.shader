Shader "Custom/NewSurfaceShader"
{
	Properties {
		texture_1 ("Texture 1", 2D) = "white" {}
		_MainTex ("Foo", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		
		sampler2D _MainTex;
		struct Input {
			float2 uv_MainTex;
		};
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)
		
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
uniform sampler2D texture_1;
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
static const float4 p_o12574_albedo_color = tofloat4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
static const float p_o12574_metallic = 0.000000000;
static const float p_o12574_roughness = 0.110000000;
static const float p_o12574_emission_energy = 0.000000000;
static const float p_o12574_normal = 1.000000000;
static const float p_o12574_ao = 1.000000000;
static const float p_o12574_depth_scale = 1.000000000;
float o12574_input_depth_tex(float2 uv, float _seed_variation_) {
return 0.0;
}
static const float p_o12612_amount = 1.000000000;
static const float seed_o12596 = 0.389765739;
static const float p_o12596_count = 25.000000000;
static const float p_o12596_scale_x = 0.700000000;
static const float p_o12596_scale_y = 0.700000000;
static const float p_o12596_rotate = 0.000000000;
static const float p_o12596_scale = 0.000000000;
static const float p_o12596_value = 0.800000000;
static const float p_o12601_default_in1 = 0.000000000;
static const float p_o12601_default_in2 = 0.000000000;
static const float p_o12603_value = 0.500000000;
static const float p_o12603_width = 0.113600000;
static const float p_o12603_contrast = 0.000000000;
static const float p_o12594_default_in1 = 0.000000000;
static const float p_o12594_default_in2 = 0.000000000;
static const float seed_o12593 = 0.042548649;
static const float p_o12593_default_in1 = 0.000000000;
static const float p_o12580_repeat = 1.000000000;
static const float p_o12580_gradient_0_pos = 0.000000000;
static const float4 p_o12580_gradient_0_col = tofloat4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
static const float p_o12580_gradient_1_pos = 1.000000000;
static const float4 p_o12580_gradient_1_col = tofloat4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
float4 o12580_gradient_gradient_fct(float x) {
  if (x < p_o12580_gradient_0_pos) {
    return p_o12580_gradient_0_col;
  } else if (x < p_o12580_gradient_1_pos) {
    return lerp(p_o12580_gradient_0_col, p_o12580_gradient_1_col, ((x-p_o12580_gradient_0_pos)/(p_o12580_gradient_1_pos-p_o12580_gradient_0_pos)));
  }
  return p_o12580_gradient_1_col;
}
static const float p_o12600_sides = 6.000000000;
static const float p_o12600_radius = 1.000000000;
static const float p_o12600_edge = 2.000000000;
float o12596_input_in(float2 uv, float _seed_variation_) {
float4 o12580_0_1_rgba = o12580_gradient_gradient_fct(frac(p_o12580_repeat*1.41421356237*length(frac((uv))-tofloat2(0.5, 0.5))));
float o12593_0_clamp_false = (dot((o12580_0_1_rgba).rgb, tofloat3(1.0))/3.0)-(_Time.y*.6-param_rnd(0,1, (seed_o12593+frac(_seed_variation_))+16.455979));
float o12593_0_clamp_true = clamp(o12593_0_clamp_false, 0.0, 1.0);
float o12593_0_2_f = o12593_0_clamp_false;
float o12594_0_clamp_false = frac(o12593_0_2_f);
float o12594_0_clamp_true = clamp(o12594_0_clamp_false, 0.0, 1.0);
float o12594_0_1_f = o12594_0_clamp_false;
float o12603_0_step = clamp((o12594_0_1_f - (p_o12603_value))/max(0.0001, p_o12603_width)+0.5, 0.0, 1.0);
float o12603_0_false = clamp((min(o12603_0_step, 1.0-o12603_0_step) * 2.0) / (1.0 - p_o12603_contrast), 0.0, 1.0);
float o12603_0_true = 1.0-o12603_0_false;float o12603_0_1_f = o12603_0_false;
float o12600_0_1_f = shape_circle((uv), p_o12600_sides, p_o12600_radius*1.0, p_o12600_edge*1.0);
float o12601_0_clamp_false = o12603_0_1_f*o12600_0_1_f;
float o12601_0_clamp_true = clamp(o12601_0_clamp_false, 0.0, 1.0);
float o12601_0_1_f = o12601_0_clamp_false;
return o12601_0_1_f;
}
float o12596_input_mask(float2 uv, float _seed_variation_) {
return 1.0;
}
float4 splatter_o12596(float2 uv, int count, inout float3 instance_uv, float2 seed, float _seed_variation_) {
	float c = 0.0;
	float3 rc = tofloat3(0.0);
	float3 rc1;
	for (int i = 0; i < count; ++i) {
		seed = rand2(seed);
		rc1 = rand3(seed);
		float mask = o12596_input_mask(frac(seed+tofloat2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			float2 pv = frac(uv - seed)-tofloat2(0.5);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o12596_rotate * 0.01745329251;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = tofloat2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv *= (seed.y-0.5)*2.0*p_o12596_scale+1.0;
			pv /= tofloat2(p_o12596_scale_x, p_o12596_scale_y);
			pv += tofloat2(0.5);
			seed = rand2(seed);
			float2 clamped_pv = clamp(pv, tofloat2(0.0), tofloat2(1.0));
			if (pv.x != clamped_pv.x || pv.y != clamped_pv.y) {
				continue;
			}
			float2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o12596_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o12596_value*seed.x);
			c = max(c, c1);
			rc = lerp(rc, rc1, step(c, c1));
			instance_uv = lerp(instance_uv, tofloat3(full_uv, seed.x), step(c, c1));
		}
	}
	return tofloat4(rc, c);
}
float o12612_input_in(float2 uv, float _seed_variation_) {
float3 o12596_0_instance_uv = tofloat3(0.0);
float4 o12596_0_rch = splatter_o12596((uv), int(p_o12596_count), o12596_0_instance_uv, tofloat2(float((seed_o12596+frac(_seed_variation_)))), _seed_variation_);float o12596_0_1_f = o12596_0_rch.a;
return o12596_0_1_f;
}
float3 nm_o12612(float2 uv, float amount, float size, float _seed_variation_) {
	float3 e = tofloat3(1.0/size, -1.0/size, 0);
	float2 rv;
	if (2 == 0) {
		rv = tofloat2(1.0, -1.0)*o12612_input_in(uv+e.xy, _seed_variation_);
		rv += tofloat2(-1.0, 1.0)*o12612_input_in(uv-e.xy, _seed_variation_);
		rv += tofloat2(1.0, 1.0)*o12612_input_in(uv+e.xx, _seed_variation_);
		rv += tofloat2(-1.0, -1.0)*o12612_input_in(uv-e.xx, _seed_variation_);
		rv += tofloat2(2.0, 0.0)*o12612_input_in(uv+e.xz, _seed_variation_);
		rv += tofloat2(-2.0, 0.0)*o12612_input_in(uv-e.xz, _seed_variation_);
		rv += tofloat2(0.0, 2.0)*o12612_input_in(uv+e.zx, _seed_variation_);
		rv += tofloat2(0.0, -2.0)*o12612_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/128.0;
	} else if (2 == 1) {
		rv = tofloat2(3.0, -3.0)*o12612_input_in(uv+e.xy, _seed_variation_);
		rv += tofloat2(-3.0, 3.0)*o12612_input_in(uv-e.xy, _seed_variation_);
		rv += tofloat2(3.0, 3.0)*o12612_input_in(uv+e.xx, _seed_variation_);
		rv += tofloat2(-3.0, -3.0)*o12612_input_in(uv-e.xx, _seed_variation_);
		rv += tofloat2(10.0, 0.0)*o12612_input_in(uv+e.xz, _seed_variation_);
		rv += tofloat2(-10.0, 0.0)*o12612_input_in(uv-e.xz, _seed_variation_);
		rv += tofloat2(0.0, 10.0)*o12612_input_in(uv+e.zx, _seed_variation_);
		rv += tofloat2(0.0, -10.0)*o12612_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/512.0;
	} else if (2 == 2) {
		rv = tofloat2(2.0, 0.0)*o12612_input_in(uv+e.xz, _seed_variation_);
		rv += tofloat2(-2.0, 0.0)*o12612_input_in(uv-e.xz, _seed_variation_);
		rv += tofloat2(0.0, 2.0)*o12612_input_in(uv+e.zx, _seed_variation_);
		rv += tofloat2(0.0, -2.0)*o12612_input_in(uv-e.zx, _seed_variation_);
		rv *= size*amount/64.0;
	} else {
		rv = tofloat2(1.0, 0.0)*o12612_input_in(uv+e.xz, _seed_variation_);
		rv += tofloat2(0.0, 1.0)*o12612_input_in(uv+e.zx, _seed_variation_);
		rv += tofloat2(-1.0, -1.0)*o12612_input_in(uv, _seed_variation_);
		rv *= size*amount/20.0;
	}
	return tofloat3(0.5)+0.5*normalize(tofloat3(rv, -1.0));
}
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
	  		float _seed_variation_ = 0.0;
			float2 uv = IN.uv_MainTex;
float4 o145910_0 = textureLod(texture_1, uv, 0.0);
float3 o12612_0_1_rgb = nm_o12612((uv), p_o12612_amount, 32.000000000, _seed_variation_);

			o.Albedo = ((o145910_0).rgb).rgb*p_o12574_albedo_color.rgb;
			o.Metallic = 1.0*p_o12574_metallic;
			o.Smoothness = 1.0-1.0*p_o12574_roughness;
			o.Alpha = 1.0;
			o.Normal = o12612_0_1_rgb*tofloat3(-1.0, 1.0, -1.0)+tofloat3(1.0, 0.0, 1.0);

		}
		ENDCG
	}
	FallBack "Diffuse"
}



