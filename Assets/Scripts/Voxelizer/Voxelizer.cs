using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Voxelizer : MonoBehaviour
{

    #region -- 資源參考區 --

    [SerializeField, Range(0, 1), Tooltip("控制生成方塊的密度")] float _density = 0.05f;
    [SerializeField, Range(0, 10), Tooltip("控制生成方塊的大小")] float _scale = 1;

    [SerializeField, Range(0, 20), Tooltip("控制方塊變形後的長度")] float _stretch = 5;
    [SerializeField, Range(0, 1000), Tooltip("控制方塊變形後上升的最大距離")] float _fallDistance = 1;
    [SerializeField, Range(0, 10), Tooltip("控制方塊變形後的隨機移動範圍")] float _fluctuation = 1;

    //用於Mesh變換物體的Renderer
    [SerializeField] Renderer[] _linkedRenderers;

    #endregion

    #region -- 變數參考區 --

    private MaterialPropertyBlock _sheet;
    private Mesh _gridMesh;

    #endregion

    #region -- 初始化/運作 --

    static class ShaderIDs
    {
        public static readonly int VoxelParams = Shader.PropertyToID("_VoxelParams");
        public static readonly int AnimParams = Shader.PropertyToID("_AnimParams");
        public static readonly int EffectVector = Shader.PropertyToID("_EffectVector");
    }

    void Update()
    {
        if (_sheet == null) _sheet = new MaterialPropertyBlock();

        var vparams = new Vector2(_density, _scale);
        var aparams = new Vector3(_stretch, _fallDistance, _fluctuation);

        var fwd = transform.forward / transform.localScale.z;
        var dist = Vector3.Dot(fwd, transform.position);
        var vector = new Vector4(fwd.x, fwd.y, fwd.z, dist);

        _sheet.SetVector(ShaderIDs.VoxelParams, vparams);
        _sheet.SetVector(ShaderIDs.AnimParams, aparams);
        _sheet.SetVector(ShaderIDs.EffectVector, vector);

        if (_linkedRenderers != null)
            foreach (var r in _linkedRenderers) r.SetPropertyBlock(_sheet);
    }

    void OnDrawGizmos()
    {
        if (_gridMesh == null) InitGridMesh();

        Gizmos.matrix = transform.localToWorldMatrix;

        Gizmos.color = new Color(1, 1, 0, 0.5f);
        Gizmos.DrawWireMesh(_gridMesh);
        Gizmos.DrawWireMesh(_gridMesh, Vector3.forward);

        Gizmos.color = new Color(1, 0, 0, 0.5f);
        Gizmos.DrawWireCube(Vector3.forward / 2, new Vector3(0.02f, 0.02f, 1));
    }

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

    #endregion

    #region -- 方法參考區 --

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

        _gridMesh = new Mesh();
        _gridMesh.hideFlags = HideFlags.DontSave;
        _gridMesh.SetVertices(vertices);
        _gridMesh.SetNormals(vertices);
        _gridMesh.SetIndices(indices.ToArray(), MeshTopology.Lines, 0);
        _gridMesh.UploadMeshData(true);
    }

    /// <summary>
    /// RGB To HSV
    /// </summary>
    Vector4 ColorToHsvm(Color color)
    {
        var max = color.maxColorComponent;
        Color.RGBToHSV(color / max, out float h, out float s, out float v);
        return new Vector4(h, s, v, max);
    }

    #endregion

}
