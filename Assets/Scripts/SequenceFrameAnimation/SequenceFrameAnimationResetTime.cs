using UnityEngine;
using UnityEngine.UI;

public class SequenceFrameAnimationResetTime : MonoBehaviour
{

	#region -- 資源參考區 --

	[SerializeField] private KeyCode animateKeyCode = KeyCode.Keypad0;
    [SerializeField] private KeyCode stopAnimateKeyCode = KeyCode.KeypadEnter;

    #endregion

    #region -- 變數參考區 --

    private Material material;

	#endregion
	
    #region -- 初始化/運作 --

	private void Awake()
	{

		material = this.GetComponent<Image>().material;

    }

	private void Update()
	{

		if (Input.GetKeyUp(animateKeyCode)) AnimateShader();
        if (Input.GetKeyUp(stopAnimateKeyCode)) StopAnimateShader();

    }

    #endregion

    #region -- 方法參考區 --

    private void AnimateShader()
    {

		if(material.IsKeywordEnabled("_USETIME") == false)
		{
            material.SetFloat("_ResetTime", Time.timeSinceLevelLoad);
            material.EnableKeyword("_USETIME");
        }

    }

    private void StopAnimateShader()
    {
        if (material.IsKeywordEnabled("_USETIME") == true)
        {
            material.DisableKeyword("_USETIME");
        }
    }

    #endregion

}