using UnityEngine;

[ExecuteInEditMode]
public class GaussianBlur : MonoBehaviour
{
    #region -- 資源參考區 --

    [SerializeField, Range(0, 8), Tooltip("迭代次數")]
    int _iteration = 4;

    [SerializeField, Tooltip("需要模糊的RenderTexture")]
    RenderTexture source;

    [SerializeField, Tooltip("模糊後的RenderTexture")]
    RenderTexture destination;

    #endregion

    #region -- 初始化/運作 --

    // Update is called once per frame
    void Update()
    {
        Blur();
    }

    #endregion

    #region -- 方法參考區 --

    /// <summary>
    /// 設置需要模糊的RenderTexture
    /// </summary>
    public void SetSourceRenderTexture(RenderTexture source)
    {
        this.source = source;
    }

    /// <summary>
    /// 取得模糊後的RenderTexture
    /// </summary>
    public RenderTexture GetDestinationRenderTexture()
    {
        return destination;
    }

    private void Blur()
    {
        if (source == null || destination == null) { return; }

        Shader _shader = Shader.Find("JHome/Gaussian Blur");
        Material _material;
        _material = new Material(_shader); // 使用Shader創建新的材質
        _material.hideFlags = HideFlags.HideAndDontSave; // 隱藏並避免材質被保存到場景中

        RenderTexture rt1, rt2; // 儲存中間渲染的RenderTexture

        rt1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2); // 創建一個一半大小的RenderTexture
        rt2 = RenderTexture.GetTemporary(source.width / 2, source.height / 2); // 創建一個一半大小的RenderTexture
        Graphics.Blit(source, rt1); // 將源RenderTexture複製到rt1中

        // 執行迭代次數的運算
        for (var i = 0; i < _iteration; i++)
        {
            Graphics.Blit(rt1, rt2, _material, 1); // 使用指定的材質內的特定shader通道對rt1進行影像處理，並將結果複製到rt2中
            Graphics.Blit(rt2, rt1, _material, 2); // 使用指定的材質內的特定shader通道對rt2進行影像處理，並將結果複製到rt1中
        }

        Graphics.Blit(rt1, destination); // 最終將處理後的rt1複製到目標RenderTexture中

        RenderTexture.ReleaseTemporary(rt1); // 釋放rt1所占用的記憶體
        RenderTexture.ReleaseTemporary(rt2); // 釋放rt2所占用的記憶體
    }

    #endregion
}
