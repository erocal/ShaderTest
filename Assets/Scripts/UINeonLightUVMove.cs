using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UINeonLightUVMove : MonoBehaviour
{
    [Tooltip("更新間隔")]
    [SerializeField, Range(0.05f, 0.15f)] private float updateInterval = 0.1f;

    [Tooltip("Y軸偏移值")]
    private float yOffsetRate = 1f;

    private Material uiNeonLightMaterial;
    private List<Vector2> offset = new List<Vector2>();
    Vector2 triangleLightOffset;
    Vector2 singleLightOffset;

    private float triangleLightTimer = 0f;
    private float singleLightTimer = 0f;


    private void Awake()
    {
        uiNeonLightMaterial = GetComponent<Image>().material;

        offset.Add(new Vector2(0, 0));
        triangleLightOffset = offset[0];
        offset.Add(new Vector2(0, 0));
        singleLightOffset = offset[1];
    }

    void FixedUpdate()
    {
        TriangleLightTextureScroll();
        SingleLightTextureScroll();
    }

    /// <summary>
    /// 控制三角光條貼圖的滾動
    /// </summary>
    private void TriangleLightTextureScroll()
    {
        triangleLightTimer += Time.fixedDeltaTime;

        // 如果計時器超過更新間隔，更新偏移值并重置計時器
        if (triangleLightTimer >= updateInterval)
        {
            // 更新Y軸偏移值
            triangleLightOffset.y += yOffsetRate * triangleLightTimer;

            triangleLightOffset.y %= 1f;

            uiNeonLightMaterial.SetFloat("_TriangleLightTextureScrollSpeed", triangleLightOffset.y);

            // 重置計時器
            triangleLightTimer = 0f;
        }
    }

    /// <summary>
    /// 控制單個光條貼圖的滾動
    /// </summary>
    private void SingleLightTextureScroll()
    {
        singleLightTimer += Time.fixedDeltaTime;

        // 如果計時器超過更新間隔，更新偏移值并重置計時器
        if (singleLightTimer >= updateInterval)
        {
            // 更新Y軸偏移值
            singleLightOffset.y += yOffsetRate * singleLightTimer;

            singleLightOffset.y %= 1f;

            uiNeonLightMaterial.SetFloat("_SingleLightTextureScrollSpeed", singleLightOffset.y);

            // 重置計時器
            singleLightTimer = 0f;
        }
    }
}
