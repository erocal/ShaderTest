using UnityEngine;

public class EarthRotate : MonoBehaviour
{
    [Header("旋轉速度")]
    [SerializeField] private float rotationSpeed = 10f;

    // 傾斜角度
    public float tiltAngle = 23.5f; // 地球傾斜角度為23.5度

    // Update is called once per frame
    void Update()
    {
        // 每幀自轉物件
        transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);

        // 傾斜自轉軸向
        Vector3 tiltAxis = Quaternion.Euler(tiltAngle, 0f, 0f) * Vector3.up;
        transform.Rotate(tiltAxis, rotationSpeed * Time.deltaTime);
    }
}
