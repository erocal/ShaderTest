using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class ColorAnimationCurveGradient : MonoBehaviour
{

	#region -- 資源參考區 --

	[SerializeField] private Gradient gradient;
	[SerializeField] private AnimationCurve animationCurve;
	[SerializeField] private float duration;

	#endregion
	
	#region -- 變數參考區 --

	MeshRenderer meshRenderer;
	MaterialPropertyBlock materialPropertyBlock;

	float currentTime = 0f;

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
		meshRenderer = GetComponent<MeshRenderer>();
        materialPropertyBlock = new MaterialPropertyBlock();
    }

	private void Update()
	{
		if (duration <= 0f) return;

		currentTime = Mathf.Repeat(currentTime + Time.deltaTime, duration);

		var colorProgress = animationCurve.Evaluate(currentTime / duration);
		var newColor = gradient.Evaluate(colorProgress);
		materialPropertyBlock.SetColor("_Color", newColor);
        meshRenderer.SetPropertyBlock(materialPropertyBlock);

    }

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}
