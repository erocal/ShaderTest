using UnityEngine;
using UnityEditor;
using System.IO;

public class FileMover : EditorWindow
{
    private string fileExtension = ".txt"; // 預設副檔名
    private string targetFolderPath = "Null"; // 預設目標資料夾

    [MenuItem("Tools/File Mover")]
    public static void ShowWindow()
    {
        GetWindow<FileMover>("File Mover");
    }

    private void OnGUI()
    {
        GUILayout.Label("Move Files to Folder", EditorStyles.boldLabel);

        fileExtension = EditorGUILayout.TextField("File Extension", fileExtension);

        EditorGUILayout.LabelField("Target Folder");

        Rect rect = EditorGUILayout.BeginHorizontal();
        EditorGUI.DrawRect(rect, new Color(0.3f, 0.3f, 0.3f));
        EditorGUILayout.LabelField($"{targetFolderPath}");
        EditorGUILayout.EndHorizontal();

        Rect dropArea = GUILayoutUtility.GetRect(0.0f, 100.0f, GUILayout.ExpandWidth(true));
        GUI.Box(dropArea, "Drag & Drop Folder Here");

        // 檢查拖拽事件
        if (dropArea.Contains(Event.current.mousePosition))
        {
            if (Event.current.type == EventType.DragUpdated)
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                Event.current.Use();
            }
            else if (Event.current.type == EventType.DragPerform)
            {
                DragAndDrop.AcceptDrag();
                foreach (var draggedObject in DragAndDrop.objectReferences)
                {
                    if (draggedObject is DefaultAsset)
                    {
                        string path = AssetDatabase.GetAssetPath(draggedObject);
                        if (AssetDatabase.IsValidFolder(path))
                        {
                            targetFolderPath = path;
                        }
                    }
                }
                Event.current.Use();
            }
        }

        if (GUILayout.Button("Move Files"))
        {
            MoveFilesToFolder(fileExtension, targetFolderPath);
        }
    }

    private void MoveFilesToFolder(string extension, string targetFolder)
    {
        // 確保目標資料夾存在
        if (!AssetDatabase.IsValidFolder(targetFolder))
        {
            Directory.CreateDirectory(targetFolder);
            AssetDatabase.Refresh();
        }

        // 搜尋所有檔案
        string[] guids = AssetDatabase.FindAssets("");

        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);

            // 檢查副檔名是否符合
            if (Path.GetExtension(path) == extension)
            {
                string fileName = Path.GetFileName(path);
                string newPath = Path.Combine(targetFolder, fileName);

                // 移動檔案
                AssetDatabase.MoveAsset(path, newPath);
                Debug.Log($"Moved {fileName} to {newPath}");
            }
        }

        AssetDatabase.Refresh();
        Debug.Log("File move completed.");
    }
}
