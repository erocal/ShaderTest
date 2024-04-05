using UnityEngine;
using UnityEngine.UI;

public class CustomImage : Image
{
    #region -- 資源參考區 --

    [Header("自訂調整數值")]
    [Header("Collider")]
    [Tooltip("是否使用第一個獲取的Collider2D作為觸發範圍")]
    [SerializeField] private bool useCollider2D;

    [Tooltip("透明度檢測的閾值")]
    [SerializeField, Range(0, 1f)] private float alphaHitTestMinimumThreshold;

    [Header("變形")]
    [SerializeField, Tooltip("右上")]
    private Vector2 rtOffset;
    [SerializeField, Tooltip("右下")]
    private Vector2 rbOffset;
    [SerializeField, Tooltip("左上")]
    private Vector2 ltOffset;
    [SerializeField, Tooltip("左下")]
    private Vector2 lbOffset;

    #endregion

    #region -- 變數參考區 --

    private Collider2D currentCollider2D;

    #endregion

    #region -- 初始化/運作 --

    private void Update()
    {
        base.alphaHitTestMinimumThreshold = alphaHitTestMinimumThreshold;
        GetCurrentCollider2D();
    }

    #endregion

    #region -- 方法參考區 --

    public override bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera)
    {
        bool isRaycast = base.IsRaycastLocationValid(screenPoint, eventCamera);

        if (isRaycast && currentCollider2D != null)
        {
            return currentCollider2D.OverlapPoint(screenPoint);
        }

        return isRaycast;
    }

    private void GetCurrentCollider2D()
    {
        if (useCollider2D) currentCollider2D = GetComponent<Collider2D>();
        else currentCollider2D = null;
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        base.OnPopulateMesh(vh);
        int vertexCount = vh.currentVertCount;
        for (int i = 0; i < vertexCount; i++)
        {
            UIVertex vertex = new UIVertex();
            vh.PopulateUIVertex(ref vertex, i);
            vertex.position += GetOffset(i);
            vh.SetUIVertex(vertex, i);
        }
    }


    /// <summary>
    /// 獲取偏移量
    /// </summary>
    private Vector3 GetOffset(int i)
    {
        if (i == 0)
        {
            return lbOffset;
        }
        else if (i == 1)
        {
            return ltOffset;
        }
        else if (i == 2)
        {
            return rtOffset;
        }
        else if (i == 3)
        {
            return rbOffset;
        }
        return Vector3.zero;
    }

    #endregion

}
