using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class OutlineBakeMeshTool : EditorWindow
{

    #region -- 變數參考區 --

    private List<GameObject> gameObjectsList = new List<GameObject>();
    private Vector2 scrollPosition;

    private static HashSet<Mesh> registeredMeshes = new HashSet<Mesh>();
    private static Dictionary<Mesh, Mesh> savedMeshes = new Dictionary<Mesh, Mesh>();

    [Serializable]
    private class ListVector3
    {
        public List<Vector3> data;
    }

    [SerializeField, HideInInspector]
    private List<Mesh> bakeKeys = new List<Mesh>();

    [SerializeField, HideInInspector]
    private List<ListVector3> bakeValues = new List<ListVector3>();

    #endregion

    [MenuItem("Tools/網格/烘焙新網格工具(For Outline)")]
    public static void ShowOutlineBakeMeshWindow()
    {
        GetWindow<OutlineBakeMeshTool>("烘焙新網格工具(For Outline)");
    }

    #region -- 初始化/運作 --

    private void OnGUI()
    {

        DragAndDropUtility.DrawDragAndDropArea(ref gameObjectsList, ref scrollPosition);

        GUILayout.Label("已儲存的 Mesh：", EditorStyles.boldLabel);

        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.Height(150));

        // 將 HashSet 轉為 List 以便於使用索引操作
        List<Mesh> registeredMeshList = new List<Mesh>(registeredMeshes);

        for (int i = 0; i < registeredMeshList.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            registeredMeshList[i] = (Mesh)EditorGUILayout.ObjectField(registeredMeshList[i], typeof(Mesh), true);

            if (GUILayout.Button("移除", GUILayout.Width(60)))
            {
                registeredMeshes.Remove(registeredMeshList[i]);
            }

            EditorGUILayout.EndHorizontal();
        }

        GUILayout.EndScrollView();

        GUILayout.Label("新生成的的 Mesh：", EditorStyles.boldLabel);

        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.Height(150));

        // 將 HashSet 轉為 List 以便於使用索引操作
        List<Mesh> savedMeshList = savedMeshes.Values.ToList();
        List<Mesh> keysToRemove = new List<Mesh>(); // 用來存儲需要移除的鍵

        // 使用 ToList() 複製一份鍵值對清單，以便在迴圈中進行移除操作
        foreach (var kvp in savedMeshes.ToList())
        {
            EditorGUILayout.BeginHorizontal();
            var meshValue = (Mesh)EditorGUILayout.ObjectField(kvp.Value, typeof(Mesh), true);

            if (GUILayout.Button("移除", GUILayout.Width(60)))
            {
                savedMeshes.Remove(kvp.Key); // 直接從原始 Dictionary 中移除
            }

            EditorGUILayout.EndHorizontal();
        }

        // 逐一移除對應的鍵
        foreach (var key in keysToRemove)
        {
            savedMeshes.Remove(key);
        }

        GUILayout.EndScrollView();

        if (GUILayout.Button("清空所有儲存Mesh"))
        {

            registeredMeshes.Clear();
            savedMeshes.Clear();

            Debug.Log("registeredMeshes 和 savedMeshes 已清空");

        }

        if (GUILayout.Button("開始烘焙"))
        {

            OnButton_BakedMesh();

        }

        if (GUILayout.Button("儲存新網格"))
        {

            OnButton_SaveMesh();
            
        }

        if (GUILayout.Button("應用新網格"))
        {

            OnButton_ApplyMesh(); 

        }

        GUILayout.Label("一鍵執行", EditorStyles.boldLabel);
        if (GUILayout.Button("一鍵烘焙儲存應用"))
        {

            OnButton_BakedMesh();
            OnButton_SaveMesh();
            OnButton_ApplyMesh();
        }

    }

    #endregion

    #region -- 方法參考區 --

    private void OnButton_BakedMesh()
    {

        foreach (GameObject gameObject in gameObjectsList)
        {
            LoadSmoothNormals(gameObject);
        }

    }

    private void OnButton_SaveMesh()
    {

        foreach (Mesh mesh in registeredMeshes)
        {
            SaveMesh(mesh, mesh.name, true, true);
        }

    }

    private void OnButton_ApplyMesh()
    {

        foreach (GameObject gameObject in gameObjectsList)
        {
            ApplySaveMesh(gameObject);
        }

    }

    /// <summary>
    /// 結合子網格與平滑法線
    /// </summary>
    private void LoadSmoothNormals(GameObject gameObject)
    {

        // Retrieve or generate smooth normals
        foreach (var meshFilter in gameObject.GetComponentsInChildren<MeshFilter>())
        {

            // Skip if smooth normals have already been adopted
            if (!registeredMeshes.Add(meshFilter.sharedMesh))
            {
                continue;
            }

            // Retrieve or generate smooth normals
            var index = bakeKeys.IndexOf(meshFilter.sharedMesh);
            var smoothNormals = (index >= 0) ? bakeValues[index].data : SmoothNormals(meshFilter.sharedMesh);// Retrieve : Generate

            // Store smooth normals in UV3
            meshFilter.sharedMesh.SetUVs(3, smoothNormals);

            // Combine submeshes
            var renderer = meshFilter.GetComponent<Renderer>();

            if (renderer != null)
            {
                CombineSubmeshes(meshFilter.sharedMesh, renderer.sharedMaterials);
            }
        }

        // Clear UV4 on skinned mesh renderers
        foreach (var skinnedMeshRenderer in gameObject.GetComponentsInChildren<SkinnedMeshRenderer>())
        {

            // Skip if UV4 has already been reset
            if (!registeredMeshes.Add(skinnedMeshRenderer.sharedMesh))
            {
                continue;
            }

            // Clear UV4
            skinnedMeshRenderer.sharedMesh.uv4 = new Vector2[skinnedMeshRenderer.sharedMesh.vertexCount];

            // Combine submeshes
            CombineSubmeshes(skinnedMeshRenderer.sharedMesh, skinnedMeshRenderer.sharedMaterials);
        }
    }

    /// <summary>
    /// 平滑法線
    /// <summary>
    private List<Vector3> SmoothNormals(Mesh mesh)
    {

        // Group vertices by location
        var groups = mesh.vertices.Select((vertex, index) => new KeyValuePair<Vector3, int>(vertex, index)).GroupBy(pair => pair.Key);

        // Copy normals to a new list
        var smoothNormals = new List<Vector3>(mesh.normals);

        // Average normals for grouped vertices
        foreach (var group in groups)
        {

            // Skip single vertices
            if (group.Count() == 1)
            {
                continue;
            }

            // Calculate the average normal
            var smoothNormal = Vector3.zero;

            foreach (var pair in group)
            {
                smoothNormal += smoothNormals[pair.Value];
            }

            smoothNormal.Normalize();

            // Assign smooth normal to each vertex
            foreach (var pair in group)
            {
                smoothNormals[pair.Value] = smoothNormal;
            }
        }

        return smoothNormals;
    }

    /// <summary>
    /// 結合子網格
    /// </summary>
    private void CombineSubmeshes(Mesh mesh, Material[] materials)
    {

        // Skip meshes with a single submesh
        if (mesh.subMeshCount == 1)
        {
            return;
        }

        // Skip if submesh count exceeds material length
        if (mesh.subMeshCount > materials.Length)
        {
            return;
        }

        // Append combined submesh
        mesh.subMeshCount++;
        mesh.SetTriangles(mesh.triangles, mesh.subMeshCount - 1);
    }

    /// <summary>
    /// 儲存網格至Assets
    /// </summary>
    private void SaveMesh(Mesh mesh, string name, bool makeNewInstance, bool optimizeMesh)
    {
        string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", name, "asset");
        if (string.IsNullOrEmpty(path)) return;

        path = FileUtil.GetProjectRelativePath(path);

        Mesh meshToSave = (makeNewInstance) ? UnityEngine.Object.Instantiate(mesh) as Mesh : mesh;

        if (optimizeMesh)
            MeshUtility.Optimize(meshToSave);

        if(savedMeshes.ContainsKey(mesh))
            savedMeshes[mesh] = meshToSave;
        else
            savedMeshes.Add(mesh, meshToSave);

        AssetDatabase.CreateAsset(meshToSave, path);
        AssetDatabase.SaveAssets();
    }

    /// <summary>
    /// 應用新網格
    /// </summary>
    private void ApplySaveMesh(GameObject gameObject)
    {

        MeshFilter meshFilter = gameObject.GetComponent<MeshFilter>();
        Mesh mesh = meshFilter.sharedMesh;

        if (!savedMeshes.ContainsKey(meshFilter.sharedMesh))
        {
            Debug.LogError($"{gameObject}應用失敗");
            return;
        }

        meshFilter.sharedMesh = savedMeshes[meshFilter.sharedMesh];

        Debug.Log($"{gameObject}應用{savedMeshes[mesh]}成功");

    }

    #endregion

}
