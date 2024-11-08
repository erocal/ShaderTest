using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GameObjectsSort : EditorWindow
{

    #region -- 變數參考區 --

    private List<GameObject> gameObjectsList = new List<GameObject>();
    private Vector2 scrollPosition;
    private Vector3 alignOrigin;
    private Vector3 interval;

    #endregion

    [MenuItem("Tools/場景物件排列工具")]
    public static void ShowGameObjectsSortWindow()
    {
        GetWindow<GameObjectsSort>("場景物件排列工具");
    }

    #region -- 初始化/運作 --

    private void OnGUI()
    {

        DragAndDropUtility.DrawDragAndDropArea(ref gameObjectsList, ref scrollPosition);

        GUILayout.Label("排列原點", EditorStyles.boldLabel);

        alignOrigin = EditorGUILayout.Vector3Field("原點", alignOrigin);

        GUILayout.Label("間隔", EditorStyles.boldLabel);

        interval = EditorGUILayout.Vector3Field("物件之間間隔", interval);

        if (GUILayout.Button("開始排列場景物件"))
        {
            SortGameObjects();
        }
    }

    #endregion

    #region -- 方法參考區 --

    /// <summary>
    /// 排列場景物件
    /// </summary>
    private void SortGameObjects()
    {

        Vector3 currentPosition = alignOrigin;

        if (gameObjectsList.Count == 0)
        {
            Debug.LogError("沒有選擇任何物件");
            return;
        }

        foreach (GameObject gameObject in gameObjectsList)
        {

            gameObject.transform.position = currentPosition;

            currentPosition += interval;

        }

        EditorUtility.DisplayDialog("排列完成 !", $"{gameObjectsList.Count}個物件排列完成 !", "確定");

    }

    #endregion

}
