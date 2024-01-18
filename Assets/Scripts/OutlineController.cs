using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[DisallowMultipleComponent]
public class OutlineController : MonoBehaviour
{
    #region -- 參數參考區 --

    [Header("Outline材質球")]
    [SerializeField] Material outlineMaterial;

    private static HashSet<Mesh> registeredMeshes = new HashSet<Mesh>();

    [SerializeField, HideInInspector]
    private List<Mesh> bakeKeys = new List<Mesh>();

    [Serializable]
    private class ListVector3
    {
        public List<Vector3> data;
    }

    [SerializeField, HideInInspector]
    private List<ListVector3> bakeValues = new List<ListVector3>();

    private Renderer cachedRenderer;

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
    {
        // 通過物體的 Renderer 組件獲取當前的 Material
        cachedRenderer = GetComponent<Renderer>();

        if (outlineMaterial != null)
        {
            ApplyOutlineToChildren(this.transform);
        }

        // 獲取或產生平滑法線
        LoadSmoothNormals();

    }

    #endregion

    #region --  方法參考區 --

    /// <summary>
    /// 平滑法線向量
    /// </summary>
    /// <param name="mesh">要進行法線平滑的網格</param>
    /// <returns>平滑後的法線向量列表</returns>
    List<Vector3> SmoothNormals(Mesh mesh)
    {

        // 將頂點按位置分組
        var groups = mesh.vertices.Select((vertex, index) => new KeyValuePair<Vector3, int>(vertex, index)).GroupBy(pair => pair.Key);

        // 複製法線到新的列表
        var smoothNormals = new List<Vector3>(mesh.normals);

        // 對分組的頂點計算平均法線
        foreach (var group in groups)
        {

            // 跳過單一頂點
            if (group.Count() == 1)
            {
                continue;
            }

            
            var smoothNormal = Vector3.zero;

            foreach (var pair in group)
            {
                // 累加分組中每個頂點的法線
                smoothNormal += smoothNormals[pair.Value];
            }

            // 將平均法線歸一化
            smoothNormal.Normalize();

            // 將平均法線指派給每個頂點
            foreach (var pair in group)
            {
                smoothNormals[pair.Value] = smoothNormal;
            }
        }

        // 返回平滑後的法線向量列表
        return smoothNormals;
    }

    /// <summary>
    /// 合併子網格
    /// </summary>
    /// <param name="mesh">要進行合併的網格</param>
    /// <param name="materials">用於新子網格的材質陣列</param>
    void CombineSubmeshes(Mesh mesh, Material[] materials)
    {

        // 只有一個子網格的網格就return
        if (mesh.subMeshCount == 1)
        {
            return;
        }

        // 子網格數量超過材質數量的網格就return
        if (mesh.subMeshCount > materials.Length)
        {
            return;
        }

        // 增加一個新的子網格
        mesh.subMeshCount++;
        // 將原始網格的三角形資訊複製到新的子網格中
        mesh.SetTriangles(mesh.triangles, mesh.subMeshCount - 1);
    }

    /// <summary>
    /// 通過遞迴的方式將材質球置入
    /// </summary>
    /// <param name="parent">母物件</param>
    void ApplyOutlineToChildren(Transform parent)
    {
        foreach (Transform child in parent)
        {
            if (child.TryGetComponent<Renderer>(out Renderer childRenderer))
            {
                ApplyOutlineMaterial(childRenderer);
            }

            ApplyOutlineToChildren(child);
        }
    }

    /// <summary>
    /// 在物件的renderer組件中添加新的材質球
    /// </summary>
    /// <param name="renderer"></param>
    void ApplyOutlineMaterial(Renderer renderer)
    {
        List<Material> materialsList = new List<Material>(renderer.sharedMaterials);
        materialsList.Add(outlineMaterial);
        renderer.materials = materialsList.ToArray();
    }

    /// <summary>
    /// 獲取或產生平滑法線
    /// </summary>
    private void LoadSmoothNormals()
    {
        foreach (var meshFilter in GetComponentsInChildren<MeshFilter>())
        {

            // 平滑法線被使用的情況下continue
            if (!registeredMeshes.Add(meshFilter.sharedMesh))
            {
                continue;
            }

            // 獲取或產生平滑法線
            var index = bakeKeys.IndexOf(meshFilter.sharedMesh);
            var smoothNormals = (index >= 0) ? bakeValues[index].data : SmoothNormals(meshFilter.sharedMesh);

            // 將平滑法線存儲在UV3通道
            meshFilter.sharedMesh.SetUVs(3, smoothNormals);

            // 合併子網格
            if (cachedRenderer != null)
            {
                CombineSubmeshes(meshFilter.sharedMesh, cachedRenderer.sharedMaterials);
            }
        }

        foreach (var skinnedMeshRenderer in GetComponentsInChildren<SkinnedMeshRenderer>())
        {

            // 如果該skinnedMeshRenderer已經被重置過，則跳過
            if (!registeredMeshes.Add(skinnedMeshRenderer.sharedMesh))
            {
                continue;
            }

            // 清空UV4通道
            skinnedMeshRenderer.sharedMesh.uv4 = new Vector2[skinnedMeshRenderer.sharedMesh.vertexCount];

            // 合併子網格
            if (cachedRenderer != null)
            {
                CombineSubmeshes(skinnedMeshRenderer.sharedMesh, cachedRenderer.sharedMaterials);
            }
        }
    }

    #endregion
}
