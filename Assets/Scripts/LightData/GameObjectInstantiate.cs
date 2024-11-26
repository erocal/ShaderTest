using UnityEngine;

public class GameObjectInstantiate : MonoBehaviour
{

	#region -- 資源參考區 --

	[SerializeField] private GameObject InstantiatePrefab;

	#endregion
	
	#region -- 變數參考區 --

	#endregion
	
    #region -- 初始化/運作 --

	private void Awake()
	{

		Instantiate(InstantiatePrefab, this.transform);
		
	}

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}