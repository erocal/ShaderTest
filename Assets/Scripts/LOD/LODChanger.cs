using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class LODChanger : MonoBehaviour
{

    #region -- 戈方把σ跋 --
    
    [SerializeField] LODGroup lodGroup;

    #endregion

    #region -- 跑计把σ跋 --

    Camera camera;
    MeshRenderer meshRenderer;
    int preLOD = 0;

    #endregion

    #region -- ﹍て/笲 --

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

    #region -- よ猭把σ跋 --

    /// <summary>
    /// ち传ShaderLOD
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
