using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class drawWithMouse : MonoBehaviour
{

    public Camera cam;

    public Shader drawShader;

    public float brushSize, brushStrenght;

    private RenderTexture splatMap;
    private Material snowMat, drawMat;
    private RaycastHit hit;
    // Start is called before the first frame update
    void Start()
    {
        drawMat = new Material(drawShader);
        drawMat.SetVector("_Color", Color.red);

        snowMat = GetComponent<MeshRenderer>().material;

        splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);

        snowMat.SetTexture("_Splat", splatMap);
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.Mouse0)){
            if(Physics.Raycast(cam.ScreenPointToRay(Input.mousePosition), out hit)){
                drawMat.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                drawMat.SetFloat("_Strenght", brushStrenght);
                drawMat.SetFloat("_Size", brushSize);

                RenderTexture temp = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, temp);
                Graphics.Blit(temp, splatMap, drawMat);

                RenderTexture.ReleaseTemporary(temp);
            }
        }
    }
}
