using UnityEngine;

namespace ETModel
{
    public class CameraResolution : MonoBehaviour
    {
        private Camera TargetCamera;
        private bool isLandscape = true;

        private void Awake()
        {
            TargetCamera = GetComponent<Camera>();
            CheckResolution();
        }

        private void Update()
        {
            CheckResolution();
        }

        private void OnDestroy()
        {
            TargetCamera = null;
        }

        private void CheckResolution()
        {
            if (TargetCamera == null)
                return;

            float Aspect_Target = 0.0f;

            if (isLandscape) Aspect_Target = ResolutionUtility.Landscape_Aspect_Target;
            else Aspect_Target = ResolutionUtility.Portrait_Aspect_Target;

            float aspect = (float)Screen.width / Screen.height;
            if (aspect < Aspect_Target)
            {
                var newRect = new Rect(TargetCamera.rect);
                var newHeight = Screen.width / Aspect_Target;
                newRect.height = newHeight / Screen.height;
                newRect.y = (1 - newRect.height) * 0.5f;
                TargetCamera.rect = newRect;
            }
            else
            {
                TargetCamera.rect = ResolutionUtility.DefaultRect;
            }
        }

        /// <summary>
        /// ¤Á´«¿Ã¹õ¤è¦V
        /// </summary>
        public void SwitchScreenOrientation(bool isLandscape = true)
        {
            this.isLandscape = isLandscape;
        }
    }
}