using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class LODChanger : MonoBehaviour
{

    #region -- �귽�ѦҰ� --
    
    [SerializeField] LODGroup lodGroup;

    #endregion

    #region -- �ܼưѦҰ� --

    Camera camera;
    MeshRenderer meshRenderer;
    int preLOD = 0;

    #endregion

    #region -- ��l��/�B�@ --

    private void Awake()
    {
        camera = Camera.main;
        meshRenderer = GetComponent<MeshRenderer>();
    }

    private void Update()
    {
        SwitchShaderLOD();
    }

    #endregion

    #region -- ��k�ѦҰ� --

    /// <summary>
    /// ����Shader��LOD
    /// </summary>
    private void SwitchShaderLOD()
    {
        int curLOD = LODUtils.GetCurrentLODIndex(lodGroup, camera);

        if (curLOD == preLOD) return;
        else
        {
            preLOD = curLOD;
            switch(curLOD)
            {
                case 0:
                    meshRenderer.material.shader.maximumLOD = 300; 
                    break;
                case 1:
                    meshRenderer.material.shader.maximumLOD = 200;
                    break;
                case 2:
                    meshRenderer.material.shader.maximumLOD = 100;
                    break;
            }
        }
    }

    #endregion
}
