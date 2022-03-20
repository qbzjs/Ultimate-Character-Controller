using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("hello");
        // rb.useGravity = false;
        //rb.AddForce(0, 200, 500);
    }

    void FixedUpdate()
    {
        rb.AddForce(0, 0, 2000*Time.deltaTime);
    }
}
