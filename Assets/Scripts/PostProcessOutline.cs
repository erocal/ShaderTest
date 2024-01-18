using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(PostProcessOutlineRenderer), PostProcessEvent.BeforeStack, "Roystan/Post Process Outline")]
public sealed class PostProcessOutline : PostProcessEffectSettings
{
    [Header("縮放倍率")]
    public IntParameter scale = new IntParameter { value = 1 };
    [Header("輪廓顏色")]
    public ColorParameter color = new ColorParameter { value = Color.white };
    [Tooltip("在繪製邊緣所需的深度值之間的差異，由當前深度縮放")]
    [Header("深度閾值")]
    public FloatParameter depthThreshold = new FloatParameter { value = 1.5f };
    [Range(0, 1), Tooltip("表面法線和視角方向之間的點乘值將影響深度閾值的值。" + 
        "這確保與相機成直角的表面需要更大的深度閾值來繪製邊緣，避免在斜坡上繪製邊緣")]
    [Header("深度法線閾值")]
    public FloatParameter depthNormalThreshold = new FloatParameter { value = 0.5f };
    [Tooltip("縮放深度法線閾值影響深度閾值的強度")]
    [Header("深度法線閾值縮放強度")]
    public FloatParameter depthNormalThresholdScale = new FloatParameter { value = 7 };
    [Range(0, 1), Tooltip("較大的值需要法線之間的差異更大才能繪製邊緣")]
    [Header("法線閾值")]
    public FloatParameter normalThreshold = new FloatParameter { value = 0.4f };
}

public sealed class PostProcessOutlineRenderer : PostProcessEffectRenderer<PostProcessOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        // 獲取用於渲染的屬性表
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Roystan/Outline Post Process"));

        // 將設置應用於材質屬性
        sheet.properties.SetFloat("_Scale", settings.scale);
        sheet.properties.SetColor("_Color", settings.color);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);
        sheet.properties.SetFloat("_DepthNormalThreshold", settings.depthNormalThreshold);
        sheet.properties.SetFloat("_DepthNormalThresholdScale", settings.depthNormalThresholdScale);
        sheet.properties.SetFloat("_NormalThreshold", settings.normalThreshold);

        // 計算裁剪到視圖的矩陣，並將其應用於材質屬性
        Matrix4x4 clipToView = GL.GetGPUProjectionMatrix(context.camera.projectionMatrix, true).inverse;
        sheet.properties.SetMatrix("_ClipToView", clipToView);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}