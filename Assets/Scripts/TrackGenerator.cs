﻿using UnityEngine;

public class TrackGenerator : MonoBehaviour
{
    [Header("Shader to draw the Path")]
    public Shader drawShader;

    [Header("Terrain where is the Snow")]
    public GameObject terrain;
    public GameObject[] objects;
    private RenderTexture splatMap;
    private Material myMaterial, drawMat;
    private RaycastHit groundHit;

    private int _layerMask;

    private void Start() {

        objects = GameObject.FindGameObjectsWithTag("DinamicObject");

        _layerMask = LayerMask.GetMask("Ground");

        drawMat = new Material(drawShader);
        drawMat.SetVector("_Color", Color.red);

        myMaterial = terrain.GetComponent<MeshRenderer>().material;
        myMaterial.SetTexture("_Splat", splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat));

    }

    private void Update() {
        for(int i = 0; i < objects.Length; i++){
            if(Physics.Raycast(objects[i].transform.position, -Vector3.up, out groundHit, objects[i].GetComponent<SnowPrintsBehaviour>().objectDistanceToGround, _layerMask)){
                drawMat.SetVector("_Coordinate", new Vector4(groundHit.textureCoord.x, groundHit.textureCoord.y, 0, 0));
                drawMat.SetFloat("_Strenght", objects[i].GetComponent<SnowPrintsBehaviour>().objectMass);
                drawMat.SetFloat("_Size", objects[i].GetComponent<SnowPrintsBehaviour>().objectSize);

                RenderTexture temp = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, temp);
                Graphics.Blit(temp, splatMap, drawMat);

                RenderTexture.ReleaseTemporary(temp);
            }
        }
    }
    
    private void OnGUI() {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), splatMap, ScaleMode.ScaleToFit, false, 1);
    }
}
