using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancingTest : MonoBehaviour
{

    #region -- 資源參考區 --

    public Transform prefab;

    public int instances = 5000;

    public float radius = 50f;

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void Start()
	{

        MaterialPropertyBlock properties = new MaterialPropertyBlock();

        for (int i = 0; i < instances; i++)
        {

            Transform transform = Instantiate(prefab);
            transform.localPosition = Random.insideUnitSphere * radius;
            transform.SetParent(base.transform);
            
            //properties.SetColor(
            //    "_Color", new Color(Random.value, Random.value, Random.value)
            //);
            //transform.GetComponent<MeshRenderer>().SetPropertyBlock(properties);

            this.GetComponent<MeshRenderer>().material.SetColor(
                "_Color", new Color(Random.value, Random.value, Random.value)
            );

        }

    }

	private void Update()
	{
		
	}

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}