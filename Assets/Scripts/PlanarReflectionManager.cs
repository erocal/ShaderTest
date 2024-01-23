using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    Camera m_ReflectionCamera;
    Camera m_MainCamera;

    RenderTexture m_RenderTarget;

    [SerializeField]
    GameObject m_ReflectionPlane;
    [SerializeField]
    Material m_FloorMaterial;

    void Start()
    {
        // 創建一個新的GameObject來放置反射相機
        GameObject reflectionCameraGo = new GameObject("ReflectionCamera");
        m_ReflectionCamera = reflectionCameraGo.AddComponent<Camera>();
        m_ReflectionCamera.enabled = false;

        // 獲取主相機
        m_MainCamera = Camera.main;

        // 創建用於反射的渲染紋理
        m_RenderTarget = new RenderTexture(Screen.width, Screen.height, 24);
    }

    void OnPreRender()
    {
        // 在每一帧渲染之前調用
        RenderReflection();
    }

    void RenderReflection()
    {
        // 從主相機複製相機設置
        m_ReflectionCamera.CopyFrom(m_MainCamera);

        // 將相機屬性轉換到反射平面的本地空間
        Vector3 cameraDirectionWorldSpace = m_MainCamera.transform.forward;
        Vector3 cameraUpWorldSpace = m_MainCamera.transform.up;
        Vector3 cameraPositionWorldSpace = m_MainCamera.transform.position;

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

    Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
    {
        // 在相機空間中計算反射平面
        Vector3 viewPos = worldToCameraMatrix.MultiplyPoint3x4(pos);
        Vector3 viewNormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
        float w = -Vector3.Dot(viewPos, viewNormal);
        return new Vector4(viewNormal.x, viewNormal.y, viewNormal.z, w);
    }

    private void DrawQuad()
    {
        GL.PushMatrix();

        m_FloorMaterial.SetPass(0);
        // 將反射紋理設置到地板材質
        m_FloorMaterial.SetTexture("_ReflectionTex", m_RenderTarget);

        GL.LoadOrtho();

        GL.Begin(GL.QUADS);
        GL.TexCoord2(1.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 0.0f);
        GL.TexCoord2(1.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 0.0f);
        GL.End();

        GL.PopMatrix();
    }
}
