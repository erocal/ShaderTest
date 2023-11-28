using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[DisallowMultipleComponent]
public class OutlineController : MonoBehaviour
{
    #region -- �ѼưѦҰ� --

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

    private Renderer[] renderers;
    private Material outlineMaterial;

    #endregion

    #region -- ��l��/�B�@ --

    private void Awake()
    {
        // �q�L���骺 Renderer �ե������e�� Material
        Renderer renderer = GetComponent<Renderer>();

        // �ˬd�O�_�s�b�W��"Outline"�� Material
        if (renderer != null)
        {
            outlineMaterial = FindOutlineMaterial(renderer);
        }

        // ����β��ͥ��ƪk�u
        LoadSmoothNormals();

    }

    void OnDestroy()
    {
        // ����Material
        Destroy(outlineMaterial);
    }

    #endregion

    #region --  ��k�ѦҰ� --

    /// <summary>
    /// ���ƪk�u�V�q
    /// </summary>
    /// <param name="mesh">�n�i��k�u���ƪ�����</param>
    /// <returns>���ƫ᪺�k�u�V�q�C��</returns>
    List<Vector3> SmoothNormals(Mesh mesh)
    {

        // �N���I����m����
        var groups = mesh.vertices.Select((vertex, index) => new KeyValuePair<Vector3, int>(vertex, index)).GroupBy(pair => pair.Key);

        // �ƻs�k�u��s���C��
        var smoothNormals = new List<Vector3>(mesh.normals);

        // ����ժ����I�p�⥭���k�u
        foreach (var group in groups)
        {

            // ���L��@���I
            if (group.Count() == 1)
            {
                continue;
            }

            
            var smoothNormal = Vector3.zero;

            foreach (var pair in group)
            {
                // �֥[���դ��C�ӳ��I���k�u
                smoothNormal += smoothNormals[pair.Value];
            }

            // �N�����k�u�k�@��
            smoothNormal.Normalize();

            // �N�����k�u�������C�ӳ��I
            foreach (var pair in group)
            {
                smoothNormals[pair.Value] = smoothNormal;
            }
        }

        // ��^���ƫ᪺�k�u�V�q�C��
        return smoothNormals;
    }

    /// <summary>
    /// �X�֤l����
    /// </summary>
    /// <param name="mesh">�n�i��X�֪�����</param>
    /// <param name="materials">�Ω�s�l���檺����}�C</param>
    void CombineSubmeshes(Mesh mesh, Material[] materials)
    {

        // �u���@�Ӥl���檺����Nreturn
        if (mesh.subMeshCount == 1)
        {
            return;
        }

        // �l����ƶq�W�L����ƶq������Nreturn
        if (mesh.subMeshCount > materials.Length)
        {
            return;
        }

        // �W�[�@�ӷs���l����
        mesh.subMeshCount++;
        // �N��l���檺�T���θ�T�ƻs��s���l���椤
        mesh.SetTriangles(mesh.triangles, mesh.subMeshCount - 1);
    }

    /// <summary>
    /// �b Renderer �ե�W�d��W��"Outline"�� Material
    /// </summary>
    /// <param name="renderer">�ǤJ��e���� Renderer �ե�</param>
    private Material FindOutlineMaterial(Renderer renderer)
    {
        Material[] materials = renderer.materials;

        foreach (Material material in materials)
        {
            // �ˬd Material ���W�٬O�_��"Outline"
            if (material.name == "Outline")
            {
                return material;
            }
        }

        // �p�G�S�����A��^ null �αĨ���L�B�z�覡
        return null;
    }

    /// <summary>
    /// ����β��ͥ��ƪk�u
    /// </summary>
    private void LoadSmoothNormals()
    {
        foreach (var meshFilter in GetComponentsInChildren<MeshFilter>())
        {

            // ���ƪk�u�Q�ϥΪ����p�Ucontinue
            if (!registeredMeshes.Add(meshFilter.sharedMesh))
            {
                continue;
            }

            // ����β��ͥ��ƪk�u
            var index = bakeKeys.IndexOf(meshFilter.sharedMesh);
            var smoothNormals = (index >= 0) ? bakeValues[index].data : SmoothNormals(meshFilter.sharedMesh);

            // �N���ƪk�u�s�x�bUV3�q�D
            meshFilter.sharedMesh.SetUVs(3, smoothNormals);

            var renderer = meshFilter.GetComponent<Renderer>();

            // �X�֤l����
            if (renderer != null)
            {
                CombineSubmeshes(meshFilter.sharedMesh, renderer.sharedMaterials);
            }
        }

        foreach (var skinnedMeshRenderer in GetComponentsInChildren<SkinnedMeshRenderer>())
        {

            // �p�G��skinnedMeshRenderer�w�g�Q���m�L�A�h���L
            if (!registeredMeshes.Add(skinnedMeshRenderer.sharedMesh))
            {
                continue;
            }

            // �M��UV4�q�D
            skinnedMeshRenderer.sharedMesh.uv4 = new Vector2[skinnedMeshRenderer.sharedMesh.vertexCount];

            // �X�֤l����
            CombineSubmeshes(skinnedMeshRenderer.sharedMesh, skinnedMeshRenderer.sharedMaterials);
        }
    }

    #endregion
}
