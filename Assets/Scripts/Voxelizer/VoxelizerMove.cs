using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoxelizerMove : MonoBehaviour
{

    #region -- 資源參考區 --

    public float moveSpeed = .1f;

    #endregion

    #region -- 變數參考區 --

    private Vector3 startPos;

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
        startPos = transform.position;

    }

	private void Update()
	{

        // 計算移動
        Vector3 movement = new Vector3(0, 0, moveSpeed) * Time.deltaTime;

        if (transform.position.z > Vector3.forward.z) transform.position = startPos;

        // 應用移動
        transform.Translate(movement, Space.World);
    }

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}
