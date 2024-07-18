using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//在编辑器模式下也可运行
[ExecuteInEditMode]
public class Voxelizer2 : MonoBehaviour
{
    //SerializeField用于面板上显示非Public的参数
    //Range(0,1)控制可滑选的范围

    //控制生成方块的密度
    [SerializeField, Range(0, 1)] float _density = 0.05f;
    //控制生成方块的大小
    [SerializeField, Range(0, 10)] float _scale = 3;


    //动画参数
    //用于控制方块变形后的长度
    [SerializeField, Range(0, 20)] float _stretch = 5;
    //用于控制方块变形后上升的最大距离
    [SerializeField, Range(0, 1000)] float _fallDistance = 1;
    //用于控制方块变形后的随机移动范围
    [SerializeField, Range(0, 10)] float _fluctuation = 1;

    //颜色参数
    [SerializeField, ColorUsage(false, true)] Color _emissionColor1 = Color.black;
    [SerializeField, ColorUsage(false, true)] Color _emissionColor2 = Color.black;
    [SerializeField, ColorUsage(false, true)] Color _transitionColor = Color.white;
    [SerializeField, ColorUsage(false, true)] Color _lineColor = Color.white;

    //用于Mesh变换物体的Renderer
    [SerializeField] Renderer[] _renderers = null;


    //效果平面的位置与距离
    Vector4 EffectorPlane
    {
        get
        {
            //获取向前的方向
            var fwd = transform.forward / transform.localScale.z;
            //获取向前方向上的移动距离
            var dist = Vector3.Dot(fwd, transform.position);
            return new Vector4(fwd.x, fwd.y, fwd.z, dist);
        }
    }


    //将RGB颜色模型转为HSV颜色模型
    Vector4 ColorToHsvm(Color color)
    {
        //获取颜色的分量最大值
        var max = color.maxColorComponent;
        float h, s, v;
        Color.RGBToHSV(color / max, out h, out s, out v);
        return new Vector4(h, s, v, max);
    }


    //获取着色器属性的唯一标识符
    //优点：使用属性标识符比将字符串传递给所有材料属性函数更有效。
    //例如，如果您经常调用Material.SetColor或使用MaterialPropertyBlock，
    //则最好只获取一次所需属性的标识符。

    static class ShaderIDs
    {
        public static readonly int VoxelParams = Shader.PropertyToID("_VoxelParams");
        public static readonly int AnimParams = Shader.PropertyToID("_AnimParams");
        public static readonly int EmissionHsvm1 = Shader.PropertyToID("_EmissionHsvm1");
        public static readonly int EmissionHsvm2 = Shader.PropertyToID("_EmissionHsvm2");
        public static readonly int TransitionColor = Shader.PropertyToID("_TransitionColor");
        public static readonly int LineColor = Shader.PropertyToID("_LineColor");
        public static readonly int EffectorPlane = Shader.PropertyToID("_EffectorPlane");
        public static readonly int PrevEffectorPlane = Shader.PropertyToID("_PrevEffectorPlane");
        public static readonly int LocalTime = Shader.PropertyToID("_LocalTime");
    }

    //在要使用相同材质但属性稍有不同的多个对象绘制的情况下使用MaterialPropertyBlock。
    MaterialPropertyBlock _sheet;
    Vector4 _prevEffectorPlane = Vector3.one * 1e+5f;

    private void LateUpdate()
    {
        //查看渲染列表是否为空
        if (_renderers == null || _renderers.Length == 0) return;
        //创建新的MaterialPropertyBlock
        if (_sheet == null) _sheet = new MaterialPropertyBlock();

        var plane = EffectorPlane;
        // Filter out large deltas.
        //过滤掉大的三角面片
        if ((_prevEffectorPlane - plane).magnitude > 100) _prevEffectorPlane = plane;

        //存储参数
        var vparams = new Vector2(_density, _scale);
        var aparams = new Vector3(_stretch, _fallDistance, _fluctuation);
        var emission1 = ColorToHsvm(_emissionColor1);
        var emission2 = ColorToHsvm(_emissionColor2);

        //将参数传递给shader
        foreach (var renderer in _renderers)
        {
            if (renderer == null) continue;
            renderer.GetPropertyBlock(_sheet);
            _sheet.SetVector(ShaderIDs.VoxelParams, vparams);
            _sheet.SetVector(ShaderIDs.AnimParams, aparams);
            _sheet.SetVector(ShaderIDs.EmissionHsvm1, emission1);
            _sheet.SetVector(ShaderIDs.EmissionHsvm2, emission2);
            _sheet.SetColor(ShaderIDs.TransitionColor, _transitionColor);
            _sheet.SetColor(ShaderIDs.LineColor, _lineColor);
            _sheet.SetVector(ShaderIDs.EffectorPlane, plane);
            _sheet.SetVector(ShaderIDs.PrevEffectorPlane, _prevEffectorPlane);
            //_sheet.SetFloat(ShaderIDs.LocalTime, time);
            renderer.SetPropertyBlock(_sheet);
            print(plane);
        }
    }


    //进行gizmo编辑器的实现,用于可视化Debug
    Mesh _gridMesh;

    void OnDestroy()
    {
        if (_gridMesh != null)
        {
            if (Application.isPlaying)
                Destroy(_gridMesh);
            else
                DestroyImmediate(_gridMesh);
        }
    }

    void OnDrawGizmos()
    {
        if (_gridMesh == null) InitGridMesh();

        //矩阵用于控制Gizmos跟随物体的移动而移动
        Gizmos.matrix = transform.localToWorldMatrix;

        Gizmos.color = new Color(1, 1, 0, 0.5f);
        Gizmos.DrawWireMesh(_gridMesh, Vector3.zero);
        Gizmos.DrawWireMesh(_gridMesh, Vector3.forward);

        Gizmos.color = new Color(1, 0, 0, 0.5f);
        Gizmos.DrawWireCube(Vector3.forward / 2, new Vector3(0.02f, 0.02f, 1));
    }

    void InitGridMesh()
    {
        const float ext = 0.5f;
        const int columns = 10;

        var vertices = new List<Vector3>();
        var indices = new List<int>();

        for (var i = 0; i < columns + 1; i++)
        {
            var x = ext * (2.0f * i / columns - 1);

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, -ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, +ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(-ext, x, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(+ext, x, 0));
        }

        _gridMesh = new Mesh { hideFlags = HideFlags.DontSave };
        _gridMesh.SetVertices(vertices);
        _gridMesh.SetNormals(vertices);
        _gridMesh.SetIndices(indices.ToArray(), MeshTopology.Lines, 0);
        _gridMesh.UploadMeshData(true);
    }
}