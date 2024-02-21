using UnityEngine;

public class ResolutionUtility
{
    public static readonly Vector2 LandscapeCanvasResolution = new Vector2(1920, 1080);
    public static readonly Vector2 PortraitCanvasResolution = new Vector2(1080, 1920);
    public static readonly Rect DefaultRect = new Rect(0, 0, 1, 1);
    public const float Landscape_Aspect_Target = 1.7778f;
    public const float Portrait_Aspect_Target = 0.5625f;
}