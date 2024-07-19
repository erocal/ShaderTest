using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeScaleTest : MonoBehaviour
{

	#region -- 資源參考區 --

	[SerializeField] private GameObject J_click;

	#endregion
	
	#region -- 變數參考區 --

	#endregion
	
    #region -- 初始化/運作 --

	private void Awake()
	{
		
	}

	private void Update()
	{
		
	}

    #endregion

    #region -- 方法參考區 --

    public void OnStartButton()
	{
		Time.timeScale = 1.0f;
	}

    public void OnStopButton()
    {
        Time.timeScale = 0.0f;
    }

    public void OnParticleButton()
    {
		J_click.SetActive(!J_click.activeInHierarchy);
    }

    #endregion

}
