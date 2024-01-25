using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    [Tooltip("反射平面，要進行反射的地板物件")]
    [SerializeField] GameObject m_ReflectionPlane;
    [Tooltip("地板物件的材質球，反射紋理將設置到此地板shader中的屬性")]
    [SerializeField] Material m_FloorMaterial;

    #region -- 參數參考區 --
    // 相機
    Camera m_ReflectionCamera;
    Camera m_MainCamera;

    // RenderTexture
    RenderTexture m_RenderTarget;

    #endregion

    void Start()
    {
        // 創建一個新的GameObject來放置反射相機
        GameObject reflectionCameraGo = new GameObject("ReflectionCamera");
        m_ReflectionCamera = reflectionCameraGo.AddComponent<Camera>();
        m_ReflectionCamera.enabled = false;

        // 獲取主相機
        m_MainCamera = Camera.main;

        // 創建用於反射的渲染紋理，並指定壓縮格式為 ARGB32
        m_RenderTarget = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
    }

    void OnPreRender()
    {
        // 在每一幀渲染之前調用
        RenderReflection();
    }

    private void RenderReflection()
    {
        // 從主相機複製相機設置
        m_ReflectionCamera.CopyFrom(m_MainCamera);

        // 將反射相機設為只渲染天空盒
        m_ReflectionCamera.cullingMask = 0;

        // 從主相機獲取世界空間中的相機方向、相機上方向和相機位置
        Vector3 cameraDirectionWorldSpace = m_MainCamera.transform.forward;
        Vector3 cameraUpWorldSpace = m_MainCamera.transform.up;
        Vector3 cameraPositionWorldSpace = m_MainCamera.transform.position;

        // 將相機方向、相機上方向和相機位置從世界空間轉換到反射平面的局部空間
        Vector3 cameraDirectionPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraDirectionWorldSpace);
        Vector3 cameraUpPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraUpWorldSpace);
        Vector3 cameraPositionPlaneSpace = m_ReflectionPlane.transform.InverseTransformPoint(cameraPositionWorldSpace);

        // 反轉y分量以正確反射
        cameraDirectionPlaneSpace.y *= -1f;
        cameraUpPlaneSpace.y *= -1f;
        cameraPositionPlaneSpace.y *= -1f;

        // 轉換回世界空間
        cameraDirectionWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraDirectionPlaneSpace);
        cameraUpWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraUpPlaneSpace);
        cameraPositionWorldSpace = m_ReflectionPlane.transform.TransformPoint(cameraPositionPlaneSpace);

        // 設置反射相機的位置並查看反射場景
        m_ReflectionCamera.transform.position = new Vector3(cameraPositionWorldSpace.x, -cameraPositionWorldSpace.y, -cameraPositionWorldSpace.z);
        m_ReflectionCamera.transform.LookAt(cameraPositionWorldSpace + cameraDirectionWorldSpace, new Vector3(cameraUpWorldSpace.x, -cameraUpWorldSpace.y, cameraUpWorldSpace.z));

        // 將反射相機的x軸旋轉與主相機的x軸旋轉匹配
        m_ReflectionCamera.transform.rotation = Quaternion.Euler(Camera.main.transform.rotation.eulerAngles.x, m_ReflectionCamera.transform.rotation.eulerAngles.y, m_ReflectionCamera.transform.rotation.eulerAngles.z);

        // 在相機空間中計算反射平面並設置斜向反射的投影矩陣
        Vector4 viewPlane = CameraSpacePlane(m_ReflectionCamera.worldToCameraMatrix, m_ReflectionPlane.transform.position, m_ReflectionPlane.transform.up);
        m_ReflectionCamera.projectionMatrix = m_ReflectionCamera.CalculateObliqueMatrix(viewPlane);

        // 將反射渲染到渲染目標
        m_ReflectionCamera.targetTexture = m_RenderTarget;
        m_ReflectionCamera.Render();

        DrawQuad();
    }

    /// <summary>
    /// 在相機空間中計算反射平面的法線和截距
    /// </summary>
    /// <param name="worldToCameraMatrix">世界到相機的變換矩陣</param>
    /// <param name="pos">反射平面上的一點位置</param>
    /// <param name="normal">反射平面的法線</param>
    /// <returns>返回包含反射平面法線和截距的 Vector4</returns>
    Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
    {
        // 在相機空間中計算反射平面
        Vector3 viewPos = worldToCameraMatrix.MultiplyPoint3x4(pos);
        Vector3 viewNormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
        float w = -Vector3.Dot(viewPos, viewNormal);
        return new Vector4(viewNormal.x, viewNormal.y, viewNormal.z, w);
    }

    /// <summary>
    /// 繪製帶有指定地板材質和反射紋理的四邊形。
    /// </summary>
    private void DrawQuad()
    {
        // 保存當前矩陣狀態
        GL.PushMatrix();

        // 設置渲染通道
        m_FloorMaterial.SetPass(0);
        // 將反射紋理設置到地板材質
        m_FloorMaterial.SetTexture("_ReflectionTex", m_RenderTarget);

        // 載入正交投影矩陣
        GL.LoadOrtho();

        // 開始繪製
        GL.Begin(GL.QUADS);

        // 定義四邊形頂點和紋理坐標
        GL.TexCoord2(1.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 0.0f);
        GL.TexCoord2(1.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 0.0f);

        // 結束繪製
        GL.End();

        // 恢復之前的矩陣狀態
        GL.PopMatrix();
    }
}
