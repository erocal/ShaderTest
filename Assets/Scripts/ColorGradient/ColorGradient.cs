using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class ColorGradient : MonoBehaviour
{

    #region -- 資源參考區 --

    [SerializeField] private Gradient gradient;

    #endregion

    #region -- 變數參考區 --

    MeshRenderer meshRenderer;
    MaterialPropertyBlock materialPropertyBlock;

    private readonly int width = 256;   // 生成的Texture2D的寬度
    private readonly int height = 1;    // 生成的Texture2D的高度

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{

        SetGradientTex();

    }

#if UNITY_EDITOR

    void OnValidate()
    {
        SetGradientTex();
    }

#endif

    #endregion

    #region -- 方法參考區 --

    /// <summary>
    /// 設置漸層貼圖
    /// </summary>
    private void SetGradientTex()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        materialPropertyBlock = new MaterialPropertyBlock();
        if (materialPropertyBlock != null && meshRenderer != null)
        {
            materialPropertyBlock.SetTexture("_GradientTex", GradientToTexture2D(gradient, width, height));
            meshRenderer.SetPropertyBlock(materialPropertyBlock);
        }
    }

    /// <summary>
    /// 漸變轉貼圖
    /// </summary>
    private Texture2D GradientToTexture2D(Gradient gradient, int width, int height)
    {
        Texture2D texture = new Texture2D(width, height, TextureFormat.RGBA32, false);
        for (int x = 0; x < width; x++)
        {
            Color color = gradient.Evaluate((float)x / (width - 1));
            for (int y = 0; y < height; y++)
            {
                texture.SetPixel(x, y, color);
            }
        }
        texture.wrapMode = TextureWrapMode.Clamp;
        texture.Apply();
        return texture;
    }

    #endregion

}
