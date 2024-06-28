using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class USBReplacementController : MonoBehaviour
{

    #region -- 資源參考區 --

    [SerializeField] private Shader m_replacementShader;

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void OnEnable()
    {
        if (m_replacementShader != null)
        {
            // the camera will replace all the shaders in the scene with
            // the replacement one the “RenderType” configuration must match
            // in both shader
            GetComponent<Camera>().SetReplacementShader(m_replacementShader, "RenderType");
        }
    }

    private void OnDisable()
    {
        // let's reset the default shader
        GetComponent<Camera>().ResetReplacementShader();
    }

    #endregion

    #region -- 方法參考區 --

    #endregion

}
