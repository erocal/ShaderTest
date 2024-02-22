using UnityEngine;

[ExecuteInEditMode]
public class FakeLight : MonoBehaviour
{
    public bool IsUpdateSetValue = false;
    public Color FakeLightColor;

    //20211007 擴充by Hank
    //基於美術已經在場景設置了這個腳本
    //為了便於直接套用，所以於此擴充，若不想使用的則把下面的bool設false即可
    /*public bool isUseToonSimple = true;
    public float _ToonDarkClip = 0.5f;                          //陰影範圍
    public Color _ToonDarkColor = new Color(208f / 255f, 70f / 255f, 39f / 255f, 50f / 255f);   //陰影顏色 /a=強度
    public float _EnviLightClip = 0.2f;                         //背光範圍
    public Color _EnviLightColor = new Color(36f / 255f, 56f / 255f, 86f / 255f, 20f / 255f);   //被光顏色 /a=強度*/


    void Start()
    {
        if (!IsUpdateSetValue)
        {
            SetGlobalFakeLight();
        }
    }

    void Update()
    {
        if (IsUpdateSetValue)
        {
            SetGlobalFakeLight();
        }
    }


    protected virtual void SetGlobalFakeLight() 
    {
        Shader.SetGlobalColor("_FakeLightColor", FakeLightColor);
        Shader.SetGlobalVector("_FakeLightDir", transform.forward);
        //if (isUseToonSimple) SetShaderProperty_ToonSimple();
    }

    //未來有需要時再啟用
    /*private void SetShaderProperty_ToonSimple() 
    {
        //加暗色
        Shader.SetGlobalFloat("_ToonDarkClip", this._ToonDarkClip);
        Shader.SetGlobalColor("_ToonDarkColor", this._ToonDarkColor);
        //背面環境光色
        Shader.SetGlobalFloat("_EnviLightClip", this._EnviLightClip);
        Shader.SetGlobalColor("_EnviLightColor", this._EnviLightColor);
    }*/
}