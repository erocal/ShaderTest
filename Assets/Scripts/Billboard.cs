using UnityEngine;

public class Billboard : MonoBehaviour
{
    private Camera mainCamera;

    void Start()
    {
        // 获取主相机
        mainCamera = Camera.main;
    }

    void Update()
    {
        Vector3 direction = mainCamera.transform.position - transform.position;
        transform.rotation = Quaternion.LookRotation(direction, mainCamera.transform.up);
    }
}
