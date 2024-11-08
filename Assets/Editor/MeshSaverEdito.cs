using UnityEditor;

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public static class MeshSaverEditor
{

    [MenuItem("CONTEXT/MeshFilter/Save Mesh...")]
    public static void SaveMeshInPlace(MenuCommand menuCommand)
    {
        MeshFilter meshFilter = menuCommand.context as MeshFilter;
        Mesh mesh = meshFilter.sharedMesh;
        SaveMesh(mesh, mesh.name, false, true);
    }

    [MenuItem("CONTEXT/MeshFilter/Save Mesh As New Instance...")]
    public static void SaveMeshNewInstanceItem(MenuCommand menuCommand)
    {
        MeshFilter meshFilter = menuCommand.context as MeshFilter;
        Mesh mesh = meshFilter.sharedMesh;
        SaveMesh(mesh, mesh.name, true, true);
    }

    public static void SaveMesh(Mesh mesh, string name, bool makeNewInstance, bool optimizeMesh)
    {
        string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", name, "asset");
        if (string.IsNullOrEmpty(path)) return;

        path = FileUtil.GetProjectRelativePath(path);

        Mesh meshToSave = (makeNewInstance) ? Object.Instantiate(mesh) as Mesh : mesh;

        if (optimizeMesh)
            MeshUtility.Optimize(meshToSave);

        AssetDatabase.CreateAsset(meshToSave, path);
        AssetDatabase.SaveAssets();
    }

}