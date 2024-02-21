using UnityEngine;
using UnityEngine.UI;

namespace ETModel
{
    public class CanvasScalerResolution : MonoBehaviour
    {
        private CanvasScaler TargetCanvasScaler;
        private bool isLandscape = true;

        private void Awake()
        {
            TargetCanvasScaler = GetComponent<CanvasScaler>();
            CheckResolution();
        }

        private void Update()
        {
            CheckResolution();
        }

        private void OnDestroy()
        {
            TargetCanvasScaler = null;
        }

        private void CheckResolution()
        {
            /// 根據傳入的螢幕方向，對CanvasResolution進行切換
            Vector2 canvasResolution = new Vector2();

            float TargetAspect_Target = 0f;

            if (this.isLandscape)
            {
                canvasResolution = ResolutionUtility.LandscapeCanvasResolution;
                TargetAspect_Target = ResolutionUtility.Landscape_Aspect_Target;
            }
            else
            {
                canvasResolution = ResolutionUtility.PortraitCanvasResolution;
                TargetAspect_Target = ResolutionUtility.Portrait_Aspect_Target;
            }

            TargetCanvasScaler.referenceResolution = canvasResolution;

#if !UNITY_2020_3_20
            if (TargetCanvasScaler == null)
                return;

            float aspect = (float)Screen.width / Screen.height;

            if (aspect < TargetAspect_Target)
            {
                var newCanvasResolution = new Vector2(TargetCanvasScaler.referenceResolution.x, TargetCanvasScaler.referenceResolution.y);
                newCanvasResolution.y = newCanvasResolution.x / aspect;
                TargetCanvasScaler.referenceResolution = newCanvasResolution;
            }
            else
            {
                TargetCanvasScaler.referenceResolution = canvasResolution;
            }
#endif

        }

        /// <summary>
        /// 切換螢幕方向
        /// </summary>
        public void SwitchScreenOrientation(bool isLandscape = true)
        {
            this.isLandscape = isLandscape;
        }
    }
}