using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class USBSimpleColorController : MonoBehaviour
{

    #region -- 資源參考區 --

    public ComputeShader m_shader;
    public Texture m_tex;

    #endregion

    #region -- 變數參考區 --

    RenderTexture m_mainTex;
    int m_texSize = 256;
    Renderer m_rend;

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{

        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0,
        RenderTextureFormat.ARGB32);
        // enable random writing
        m_mainTex.enableRandomWrite = true;
        // let’s create the texture
        m_mainTex.Create();

        // get the material’s renderer component
        m_rend = GetComponent<Renderer>();
        // make the object visible
        m_rend.enabled = true;
        // send the texture to the Compute shader
        m_shader.SetTexture(0, "Result", m_mainTex);
        m_shader.SetTexture(0, "ColTex", m_tex);

        // generate the threads group to process the texture
        m_shader.Dispatch(0, m_texSize / 8, m_texSize / 8, 1);
        
        m_rend.material.SetTexture("_MainTex", m_mainTex);

    }

	private void Update()
	{
		
	}

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}