using UnityEditor;

[CustomEditor(typeof(CustomImage))]
public class CustomImageEditor : Editor
{
    public override void OnInspectorGUI()
    {
        // 更新序列化物件
        serializedObject.Update();

        // 顯示Image的預設Inspector面板
        base.OnInspectorGUI();

        // 應用所有的修改
        serializedObject.ApplyModifiedProperties();
    }
}
