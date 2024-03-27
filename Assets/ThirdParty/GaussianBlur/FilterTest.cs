using UnityEngine;

[ExecuteInEditMode]
public class FilterTest : MonoBehaviour
{
    enum DownSampleMode { Off, Half, Quarter }

    [SerializeField]
    Shader _shader; // 儲存用於影像處理的Shader

    [SerializeField]
    DownSampleMode _downSampleMode = DownSampleMode.Quarter;

    [SerializeField, Range(0, 8)]
    int _iteration = 4; // 迭代次數

    Material _material;

    // 當影像渲染時呼叫，處理輸入和輸出的RenderTexture
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null) // 如果材質為空，則初始化材質
        {
            _material = new Material(_shader); // 使用Shader創建新的材質
            _material.hideFlags = HideFlags.HideAndDontSave; // 隱藏並避免材質被保存到場景中
        }

        RenderTexture rt1, rt2; // 儲存中間渲染的RenderTexture

        // 根據採樣模式選擇RenderTexture的大小和初始處理方式
        if (_downSampleMode == DownSampleMode.Half)
        {
            rt1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2); // 創建一個一半大小的RenderTexture
            rt2 = RenderTexture.GetTemporary(source.width / 2, source.height / 2); // 創建一個一半大小的RenderTexture
            Graphics.Blit(source, rt1); // 將源RenderTexture複製到rt1中
        }
        else if (_downSampleMode == DownSampleMode.Quarter)
        {
            rt1 = RenderTexture.GetTemporary(source.width / 4, source.height / 4); // 創建一個四分之一大小的RenderTexture
            rt2 = RenderTexture.GetTemporary(source.width / 4, source.height / 4); // 創建一個四分之一大小的RenderTexture
            Graphics.Blit(source, rt1, _material, 0); // 將源RenderTexture使用指定的材質複製到rt1中
        }
        else
        {
            rt1 = RenderTexture.GetTemporary(source.width, source.height); // 創建一個與源RenderTexture相同大小的RenderTexture
            rt2 = RenderTexture.GetTemporary(source.width, source.height); // 創建一個與源RenderTexture相同大小的RenderTexture
            Graphics.Blit(source, rt1); // 將源RenderTexture複製到rt1中
        }

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
}
