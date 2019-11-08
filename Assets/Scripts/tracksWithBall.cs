using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class tracksWithBall : MonoBehaviour
{
    [Header("Shader to draw the Path")]
    public Shader drawShader;

    [Header("Terrain where is the Snow")]
    public GameObject terrain;
    private Transform theObejct;

    [Range(0.001f, 0.01f)]
    public float brushSize;

    [Range(0.01f, 0.1f)]
    public float brushStrenght;

    private RenderTexture splatMap;
    private Material myMaterial, drawMat;
    private RaycastHit hit;

    private int layerMask;


    private void Start() {
        layerMask = LayerMask.GetMask("Ground");

        drawMat = new Material(drawShader);
        drawMat.SetVector("_Color", Color.red);

        myMaterial = terrain.GetComponent<MeshRenderer>().material;
        myMaterial.SetTexture("_Splat", splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat));

        theObejct = GetComponent<Transform>();
    }

    private void Update() {
        if(Physics.Raycast(theObejct.position, -Vector3.up, out hit, .8f, layerMask)){
                drawMat.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                
                drawMat.SetFloat("_Strenght", brushStrenght);
                drawMat.SetFloat("_Size", brushSize);

                RenderTexture temp = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, temp);
                Graphics.Blit(temp, splatMap, drawMat);

                RenderTexture.ReleaseTemporary(temp);
            }
    }

        private void OnGUI() {
        GUI.DrawTexture(new Rect(0, 0, 128, 128), splatMap, ScaleMode.ScaleToFit, false, 1);
    }
}
