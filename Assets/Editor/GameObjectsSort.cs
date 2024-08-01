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

        GUILayout.Label("拖曳 GameObjects 到這個區域", EditorStyles.boldLabel);

        Rect dropArea = GUILayoutUtility.GetRect(0.0f, 50.0f, GUILayout.ExpandWidth(true));
        GUI.Box(dropArea, "拖曳 GameObjects 到這裡");

        Event evt = Event.current;
        switch (evt.type)
        {
            case EventType.DragUpdated:
            case EventType.DragPerform:
                if (!dropArea.Contains(evt.mousePosition))
                    break;

                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();

                    foreach (Object draggedObject in DragAndDrop.objectReferences)
                    {
                        GameObject draggedGameObject = draggedObject as GameObject;
                        if (draggedGameObject != null && !gameObjectsList.Contains(draggedGameObject))
                        {
                            gameObjectsList.Add(draggedGameObject);
                        }
                    }
                }
                Event.current.Use();
                break;
        }

        GUILayout.Label("已儲存的 GameObjects：", EditorStyles.boldLabel);

        // 開始滾動區域
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.Height(150));

        for (int i = 0; i < gameObjectsList.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            gameObjectsList[i] = (GameObject)EditorGUILayout.ObjectField(gameObjectsList[i], typeof(GameObject), true);

            if (GUILayout.Button("移除", GUILayout.Width(60)))
            {
                gameObjectsList.RemoveAt(i);
                i--;
            }

            EditorGUILayout.EndHorizontal();
        }

        GUILayout.EndScrollView();

        if (GUILayout.Button("清空清單"))
        {
            gameObjectsList.Clear();
        }

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
