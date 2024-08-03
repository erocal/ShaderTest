Shader "Voxelizer/MeshShader"
{
    Properties
    {
        _MainTex("主纹理贴图",2D)="white"{}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM

            //声明着色器
            #pragma vertex vert 
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "SimplexNoise3D.hlsl"
            //传递给顶点着色器的数据
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            //传递给几何着色器的数据
            struct v2g
            {
                float4 vertex:POSITION;
                float3 normal:TEXCOORD0;
                //float2 uv:TEXCOORD1;

            };

            //传递给像素着色器的数据
            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 normal:TEXCOORD0;
                //float2 uv : TEXCOORD1;
                float4 color:COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //用于几何着色器的数据
            half2 _VoxelParams; // density, scale  密度，比例
            half3 _AnimParams;  // stretch, fall distance, fluctuation   伸展、下降距离、波动
            float4 _EffectorPlane;
            float4 _PrevEffectorPlane;

            //用于像素着色器的数据
            half4 _EmissionHsvm1;
            half4 _EmissionHsvm2;
            half3 _TransitionColor;
            half3 _LineColor;


            //顶点着色器
            void vert(inout v2g input)
            {

            }

            g2f VertexOutput(
                float3 position0, float3 position1,
                half3 normal0, half3 normal1, half param,
                half emission = 0, half random = 0, half2 baryCoord = 0.5
            )
            {
                g2f i;
                i.pos = UnityObjectToClipPos(float4(lerp(position0, position1, param),1));
                i.normal = normalize(lerp(normal0, normal1, param));
                i.color = float4(baryCoord, emission,random);
                return i;
            }

            // 计算方块的位置和大小
            void CubePosScale(
                float3 center, float size, float rand, float param,
                out float3 pos, out float3 scale
            )
            {
                const float VoxelScale = _VoxelParams.y;
                const float Stretch = _AnimParams.x;
                const float FallDist = _AnimParams.y;
                const float Fluctuation = _AnimParams.z;

                // Noise field
                //噪声场
                float4 snoise = snoise_grad(float3(rand * 2378.34, param * 0.8, 0));

                // Stretch/move param
                float move = saturate(param * 4 - 3);
                move = move * move;

                // Cube position
                pos = center + snoise.xyz * size * Fluctuation;
                pos.y += move * move * lerp(0.25, 1, rand) * size * FallDist;

                // Cube scale anim
                scale = float2(1 - move, 1 + move * Stretch).xyx;
                scale *= size * VoxelScale * saturate(1 + snoise.w * 2);
            }

            //哈希值，用于随机觉得面片是三角面片还是Cube
            float Hash(uint s)
            {
                s = s ^ 2747636419u;
                s = s * 2654435769u;
                s = s ^ (s >> 16);
                s = s * 2654435769u;
                s = s ^ (s >> 16);
                s = s * 2654435769u;
                return float(s) * rcp(4294967296.0); // 2^-32
            }

            //几何着色器
            [maxvertexcount(24)]
            void geom(triangle v2g input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> outStream)
            {
                //获取密度
                const float VoxelDensity = _VoxelParams.x;

                //获取传入顶点的位置
                float3 p0 = input[0].vertex.xyz;
                float3 p1 = input[1].vertex.xyz;
                float3 p2 = input[2].vertex.xyz;

                float3 p0_prev = p0;
                float3 p1_prev = p1;
                float3 p2_prev = p2;

                //获取传入顶点的法线
                float3 n0 = input[0].normal;
                float3 n1 = input[1].normal;
                float3 n2 = input[2].normal;

                //计算中心点
                float3 center = (p0 + p1 + p2) / 3;
                float size = distance(p0, center);

                //变形参数
                //将中心点变换到世界空间中
                float3 center_ws = mul(unity_ObjectToWorld, float4(center,1)).xyz;
                float param = 1 - dot(_EffectorPlane.xyz, center_ws) + _EffectorPlane.w;


                //如果变形还没开始那就将平常操作
                if (param < 0)
                {
                    outStream.Append(VertexOutput(p0, 0, n0, 0, 0, 0, 0));
                    outStream.Append(VertexOutput(p1, 0, n1, 0, 0, 0, 0));
                    outStream.Append(VertexOutput(p2, 0, n2, 0, 0, 0, 0));
                    outStream.RestartStrip();
                    return;
                }


                //变形结束后，不传递任何数据，从而使物体隐身
                if (param >= 1) return;

                // Choose cube/triangle randomly.
                //uint seed = float3(pid * 877, pid * 877, pid * 877);
                uint seed = pid * 877;
                if (Hash(seed) < VoxelDensity)
                {
                    // -- Cube --

                    // Random numbers
                    float rand1 = Hash(seed + 1);
                    float rand2 = Hash(seed + 5);

                    // Cube position and scale
                    float3 pos, pos_prev, scale, scale_prev;
                    CubePosScale(center, size, rand1, param, pos, scale);

                    // Secondary animation parameters
                    float morph = smoothstep(0, 0.25, param);        

                    float em = smoothstep(0, 0.15, param) * 2; // initial emission
                    em = min(em, 1 + smoothstep(0.8, 0.9, 1 - param));
                    em += smoothstep(0.75, 1, param); // emission while falling

                    // Cube points calculation
                    float3 pc0 = pos + float3(-1, -1, -1) * scale;
                    float3 pc1 = pos + float3(+1, -1, -1) * scale;
                    float3 pc2 = pos + float3(-1, +1, -1) * scale;
                    float3 pc3 = pos + float3(+1, +1, -1) * scale;
                    float3 pc4 = pos + float3(-1, -1, +1) * scale;
                    float3 pc5 = pos + float3(+1, -1, +1) * scale;
                    float3 pc6 = pos + float3(-1, +1, +1) * scale;
                    float3 pc7 = pos + float3(+1, +1, +1) * scale;


                    // World space to object space conversion

                    // Vertex outputs
                    float3 nc = float3(-1, 0, 0);
                    outStream.Append(VertexOutput(p0, pc2, n0, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p2, pc0, n2, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p0, pc6, n0, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p2, pc4, n2, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();

                    nc = float3(1, 0, 0);
                    outStream.Append(VertexOutput(p2, pc1, n2, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p1, pc3, n1, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p2, pc5, n2, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p1, pc7, n1, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();

                    nc = float3(0, -1, 0);
                    outStream.Append(VertexOutput(p2, pc0, n2, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p2, pc1, n2, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p2, pc4, n2, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p2, pc5, n2, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();

                    nc = float3(0, 1, 0);
                    outStream.Append(VertexOutput(p1, pc3, n1, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p0, pc2, n0, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p1, pc7, n1, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p0, pc6, n0, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();

                    nc = float3(0, 0, -1);
                    outStream.Append(VertexOutput(p2, pc1, n2, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p2, pc0, n2, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p1, pc3, n1, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p0, pc2, n0, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();

                    nc = float3(0, 0, 1);
                    outStream.Append(VertexOutput(p2, pc4, -n2, nc, morph, em, rand2, float2(0, 0)));
                    outStream.Append(VertexOutput(p2, pc5, -n2, nc, morph, em, rand2, float2(1, 0)));
                    outStream.Append(VertexOutput(p0, pc6, -n0, nc, morph, em, rand2, float2(0, 1)));
                    outStream.Append(VertexOutput(p1, pc7, -n1, nc, morph, em, rand2, float2(1, 1)));
                    outStream.RestartStrip();
                }
                else
                {
                    // -- Triangle --
                    half morph = smoothstep(0, 0.25, param);
                    //half morph = 0.25;
                    half em = smoothstep(0, 0.15, param) * 2;
                    outStream.Append(VertexOutput(p0, center, n0, n0, morph, em));
                    outStream.Append(VertexOutput(p1, center, n1, n1, morph, em));
                    outStream.Append(VertexOutput(p2, center, n2, n2, morph, em));
                    outStream.RestartStrip();
                }
            }

            //计算颜色
            half3 SelfEmission(g2f input)
            {
                half2 bcc = input.color.rg;
                half em1 = saturate(input.color.b);
                half em2 = saturate(input.color.b - 1);
                half rand = input.color.a;

                // Cube face color
                half3 face = lerp(_EmissionHsvm1.xyz, _EmissionHsvm2.xyz, rand);
                face *= lerp(_EmissionHsvm1.w, _EmissionHsvm2.w, rand);

                // Cube face attenuation
                face *= lerp(0.75, 1, smoothstep(0, 0.5, length(bcc - 0.5)));

                // Edge detection
                half2 fw = fwidth(bcc);
                half2 edge2 = min(smoothstep(0, fw * 2, bcc),
                    smoothstep(0, fw * 2, 1 - bcc));
                half edge = 1 - min(edge2.x, edge2.y);

                return
                    face * em1 +
                    _TransitionColor * em2 * face +
                    edge * _LineColor * em1;
            }

            half4 frag(g2f z):SV_Target
            {
                half4 col = half4(SelfEmission(z),1);
                return col;
            }
                ENDCG
        }
    }
    FallBack "Diffuse"
}
