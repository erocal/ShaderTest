using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomMove : MonoBehaviour
{

    #region -- 資源參考區 --

    public float moveSpeed = 5f;
    public int moveRange = 20;

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
		
	}

	private void Update()
	{

        if (this.transform.position.x <= -moveRange || this.transform.position.x >= moveRange) moveSpeed = -moveSpeed;

        // 計算移動
        Vector3 movement = new Vector3(1, 0, 0) * moveSpeed * Time.deltaTime;

        // 應用移動
        transform.Translate(movement, Space.World);
    }

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}
