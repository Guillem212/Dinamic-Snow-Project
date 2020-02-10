using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecalculateVertexScript : MonoBehaviour
{
    Mesh mesh;
    Vector3[] normals;
    Vector3[] vertices;
    List<Vector3> recuentoVertices;
    List<IndexCount> indices;

    int normalTargetIndex;

    // Start is called before the first frame update
    void Awake()
    {
        mesh = GetComponent<MeshFilter>().mesh;

        normals = mesh.normals;
        vertices = mesh.vertices;

        recuentoVertices = new List<Vector3>();
        indices = new List<IndexCount>();

        recuentoVertices.Add(vertices[0]);
        indices.Add(new IndexCount(0, 1));
        for(int i = 1; i < vertices.Length; i++){
            if(recuentoVertices.Contains(vertices[i])){
                normalTargetIndex = indices[recuentoVertices.LastIndexOf(vertices[i])].index;
                normals[normalTargetIndex] += normals[i];
                indices[recuentoVertices.LastIndexOf(vertices[i])].count += 1;
            }
            else{
                recuentoVertices.Add(vertices[i]);
                indices.Add(new IndexCount(i, 1));
            }
        }

        for(int i = 0; i < indices.Count; i++){
            normals[i] = normals[i]/indices[i].count;
            normals[i].Normalize();
        }

        for(int i = 0; i < vertices.Length; i++){
            if(recuentoVertices.Contains(vertices[i])){
                if(normals[i].y != 1)
                    normals[i] = normals[recuentoVertices.LastIndexOf(vertices[i])];
            }
        }

        mesh.normals = normals;
    }
}

public class IndexCount{
    public int index, count;

    public IndexCount(int index, int count){
        this.index = index;
        this.count = count;
    }
}
