using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveBall : MonoBehaviour
{
    private Rigidbody rb;
    private Camera cam;

    private void Start() {
        rb = GetComponent<Rigidbody>();
        cam = Camera.main;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if(Input.GetKey(KeyCode.W)){
            rb.AddForce(Vector3.forward);
        }
        if(Input.GetKey(KeyCode.A)){
            rb.AddForce(Vector3.left);
        }
        if(Input.GetKey(KeyCode.S)){
            rb.AddForce(Vector3.back);
        }
        if(Input.GetKey(KeyCode.D)){
            rb.AddForce(Vector3.right);
        }
        if(Input.GetKey(KeyCode.Space)){
            rb.AddForce(Vector3.up, ForceMode.Impulse);
        }
    }

    private void LateUpdate() {
        cam.transform.position = new Vector3(transform.position.x, cam.transform.position.y, cam.transform.position.z);
    }
}
