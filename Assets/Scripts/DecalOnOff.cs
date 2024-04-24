using UnityEngine;

[ExecuteInEditMode]
public class DecalOnOff : MonoBehaviour {

    Material mat;
    bool showDecal = false;

    private void OnMouseDown() {

        showDecal = !showDecal;
        if (showDecal) {

            mat.SetFloat("_ShowDecal", 1);
        }
        else {

            mat.SetFloat("_ShowDecal", 0);
        }
    }


    void Start() {

        mat = this.GetComponent<Renderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update() {

    }
}
