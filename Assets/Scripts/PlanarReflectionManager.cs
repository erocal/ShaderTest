
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

	[SerializeField]
	[Range(0f, 1f)]
	float m_ReflectionFactor = 0.5f;

	void Start()
	{
		GameObject reflectionCameraGo = new GameObject("ReflectionCamera");
		m_ReflectionCamera = reflectionCameraGo.AddComponent<Camera>();
		m_ReflectionCamera.enabled = false;

		m_MainCamera = Camera.main;

		m_RenderTarget = new RenderTexture(Screen.width, Screen.height, 24);
	}

	void Update()
	{
		m_FloorMaterial.SetFloat("_ReflectionFactor", m_ReflectionFactor);
	}

	void OnPreRender()
	{
		RenderReflection();
	}

	void RenderReflection()
	{
		m_ReflectionCamera.CopyFrom(m_MainCamera);

		Vector3 cameraDirectionWorldSpace = m_MainCamera.transform.forward;
		Vector3 cameraUpWorldSpace = m_MainCamera.transform.up;
		Vector3 cameraPositionWorldSpace = m_MainCamera.transform.position;

		Vector3 cameraDirectionPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraDirectionWorldSpace);
		Vector3 cameraUpPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraUpWorldSpace);
		Vector3 cameraPositionPlaneSpace = m_ReflectionPlane.transform.InverseTransformPoint(cameraPositionWorldSpace);

		cameraDirectionPlaneSpace.y *= -1f;
		cameraUpPlaneSpace.y *= -1f;
		cameraPositionPlaneSpace.y *= -1f;

		cameraDirectionWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraDirectionPlaneSpace);
		cameraUpWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraUpPlaneSpace);
		cameraPositionWorldSpace = m_ReflectionPlane.transform.TransformPoint(cameraPositionPlaneSpace);

		//m_ReflectionCamera.transform.position = new Vector3(cameraPositionWorldSpace.x, -cameraPositionWorldSpace.y, -cameraPositionWorldSpace.z);
		//m_ReflectionCamera.transform.LookAt(cameraPositionWorldSpace + cameraDirectionWorldSpace, cameraUpWorldSpace);

        m_ReflectionCamera.transform.position = new Vector3(cameraPositionWorldSpace.x, -cameraPositionWorldSpace.y, -cameraPositionWorldSpace.z);
        m_ReflectionCamera.transform.LookAt(cameraPositionWorldSpace + cameraDirectionWorldSpace, new Vector3(cameraUpWorldSpace.x, -cameraUpWorldSpace.y, cameraUpWorldSpace.z));

        // 將反射相機的 x 軸旋轉設定為主相機的 x 軸旋轉
        m_ReflectionCamera.transform.rotation = Quaternion.Euler(Camera.main.transform.rotation.eulerAngles.x, m_ReflectionCamera.transform.rotation.eulerAngles.y, m_ReflectionCamera.transform.rotation.eulerAngles.z);

        Vector4 viewPlane = CameraSpacePlane(m_ReflectionCamera.worldToCameraMatrix, m_ReflectionPlane.transform.position, m_ReflectionPlane.transform.up);
		m_ReflectionCamera.projectionMatrix = m_ReflectionCamera.CalculateObliqueMatrix(viewPlane);

		m_ReflectionCamera.targetTexture = m_RenderTarget;
		m_ReflectionCamera.Render();

		m_FloorMaterial.SetTexture("_ReflectionTex", m_RenderTarget);
	}

	Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
	{
		Vector3 viewPos = worldToCameraMatrix.MultiplyPoint3x4(pos);
		Vector3 viewNormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
		float w = -Vector3.Dot(viewPos, viewNormal);
		return new Vector4(viewNormal.x, viewNormal.y, viewNormal.z, w);
	}
}
