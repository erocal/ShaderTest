﻿using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace PathCreation.Examples
{
    public class TwistLineCreator : PathSceneTool
    {
        [Header("Road settings")]
        public float roadWidth = .4f;
        [Range(-1f, 1f)]
        public float thickness = .15f;
        public bool flattenSurface;

        [Header("Material settings")]
        public Material roadMaterial;
        public Material undersideMaterial;
        public float textureTiling = 1;

        [SerializeField] private List<GameObject> meshHolderList;

        MeshFilter meshFilter;
        MeshRenderer meshRenderer;
        Mesh mesh;
        public List<Mesh> meshList;
        CombineInstance[] combine;

        protected override void PathUpdated()
        {
            if (pathCreator != null)
            {

                meshList = new List<Mesh>()
                {
                    mesh,
                    mesh,
                    mesh
                };

                combine = new CombineInstance[meshList.Count];

                for (int i = 0; i < meshHolderList.Count; i++)
                {
                    CreateRoadMesh(i);
                    AssignMeshComponents(i);
                    AssignMaterials();
                }

                meshList.RemoveRange(0, 3);

                for (int i = 0; i < 3; i++)
                {
                    combine[i].mesh = meshList[i];
                    combine[i].transform = meshHolderList[i].transform.localToWorldMatrix;
                }

                Mesh combineMesh = new Mesh();
                combineMesh.CombineMeshes(combine);
                combineMesh.name = "combine";
                meshList.Add(combineMesh);

            }
        }

        void CreateRoadMesh(int index)
        {

            mesh = new Mesh();

            float thickness = index == 2 ? this.thickness : -this.thickness;

            Vector3[] verts = new Vector3[path.NumPoints * 8];
            Vector2[] uvs = new Vector2[verts.Length];
            Vector3[] normals = new Vector3[verts.Length];

            int numTris = 2 * (path.NumPoints - 1) + ((path.isClosedLoop) ? 2 : 0);
            int[] roadTriangles = new int[numTris * 3];
            int[] underRoadTriangles = new int[numTris * 3];
            int[] sideOfRoadTriangles = new int[numTris * 2 * 3];

            int vertIndex = 0;
            int triIndex = 0;

            // Vertices for the top of the road are layed out:
            // 0  1
            // 8  9
            // and so on... So the triangle map 0,8,1 for example, defines a triangle from top left to bottom left to bottom right.
            int[] triangleMap = { 0, 8, 1, 1, 8, 9 };
            int[] sidesTriangleMap = { 4, 6, 14, 12, 4, 14, 5, 15, 7, 13, 15, 5 };

            bool usePathNormals = !(path.space == PathSpace.xyz && flattenSurface);

            for (int i = 0; i < path.NumPoints; i++)
            {
                Vector3 localUp = (usePathNormals) ? Vector3.Cross(path.GetTangent(i), path.GetNormal(i)) : path.up;
                Vector3 localRight = (usePathNormals) ? path.GetNormal(i) : Vector3.Cross(localUp, path.GetTangent(i));

                // Find position to left and right of current path vertex
                Vector3 vertSideA = index != 0 ? path.GetPoint(i) : path.GetPoint(i) - localRight * Mathf.Abs(roadWidth);
                Vector3 vertSideB = index != 0 ? path.GetPoint(i) : path.GetPoint(i) + localRight * Mathf.Abs(roadWidth);

                // Add top of road vertices
                verts[vertIndex + 0] = vertSideA;
                verts[vertIndex + 1] = vertSideB;
                // Add bottom of road vertices
                verts[vertIndex + 2] = index == 0 ? vertSideA : vertSideA - localUp * thickness;
                verts[vertIndex + 3] = index == 0 ? vertSideB : vertSideB - localUp * thickness;

                // Duplicate vertices to get flat shading for sides of road
                verts[vertIndex + 4] = verts[vertIndex + 0];
                verts[vertIndex + 5] = verts[vertIndex + 1];
                verts[vertIndex + 6] = verts[vertIndex + 2];
                verts[vertIndex + 7] = verts[vertIndex + 3];

                // Set uv on y axis to path time (0 at start of path, up to 1 at end of path)
                uvs[vertIndex + 0] = new Vector2(0, path.times[i]);
                uvs[vertIndex + 1] = new Vector2(1, path.times[i]);

                // Top of road normals
                normals[vertIndex + 0] = localUp;
                normals[vertIndex + 1] = localUp;
                // Bottom of road normals
                normals[vertIndex + 2] = -localUp;
                normals[vertIndex + 3] = -localUp;
                // Sides of road normals
                normals[vertIndex + 4] = -localRight;
                normals[vertIndex + 5] = localRight;
                normals[vertIndex + 6] = -localRight;
                normals[vertIndex + 7] = localRight;

                // Set triangle indices
                if (i < path.NumPoints - 1 || path.isClosedLoop)
                {
                    for (int j = 0; j < triangleMap.Length; j++)
                    {
                        roadTriangles[triIndex + j] = (vertIndex + triangleMap[j]) % verts.Length;
                        // reverse triangle map for under road so that triangles wind the other way and are visible from underneath
                        underRoadTriangles[triIndex + j] = (vertIndex + triangleMap[triangleMap.Length - 1 - j] + 2) % verts.Length;
                    }
                    for (int j = 0; j < sidesTriangleMap.Length; j++)
                    {
                        sideOfRoadTriangles[triIndex * 2 + j] = (vertIndex + sidesTriangleMap[j]) % verts.Length;
                    }

                }

                vertIndex += 8;
                triIndex += 6;
            }

            mesh.Clear();
            mesh.vertices = verts;
            mesh.uv = uvs;
            mesh.normals = normals;
            mesh.subMeshCount = 3;
            mesh.SetTriangles(roadTriangles, 0);
            mesh.SetTriangles(underRoadTriangles, 1);
            mesh.SetTriangles(sideOfRoadTriangles, 2);
            mesh.RecalculateBounds();
            mesh.name = index.ToString();
            meshList.Add(mesh);

        }

        // Add MeshRenderer and MeshFilter components to this gameobject if not already attached
        void AssignMeshComponents(int index)
        {

            if (meshHolderList[index] == null)
            {
                Debug.LogError("meshHolder is empty");
                return;
            }

            meshHolderList[index].transform.rotation = Quaternion.identity;
            meshHolderList[index].transform.position = Vector3.zero;
            meshHolderList[index].transform.localScale = Vector3.one;

            // Ensure mesh renderer and filter components are assigned
            if (!meshHolderList[index].gameObject.GetComponent<MeshFilter>())
            {
                meshHolderList[index].gameObject.AddComponent<MeshFilter>();
            }
            if (!meshHolderList[index].GetComponent<MeshRenderer>())
            {
                meshHolderList[index].gameObject.AddComponent<MeshRenderer>();
            }

            meshRenderer = meshHolderList[index].GetComponent<MeshRenderer>();
            meshFilter = meshHolderList[index].GetComponent<MeshFilter>();
            if (meshList[index] == null)
            {
                meshList[index] = new Mesh();
            }
            meshFilter.sharedMesh = mesh;
        }

        void AssignMaterials()
        {
            if (roadMaterial != null && undersideMaterial != null)
            {
                meshRenderer.sharedMaterials = new Material[] { roadMaterial, undersideMaterial, undersideMaterial };
                meshRenderer.sharedMaterials[0].mainTextureScale = new Vector3(1, textureTiling);
            }
        }

    }
}