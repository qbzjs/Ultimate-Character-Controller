using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
public class jump : MonoBehaviour
{
    public float jumpForce=10f;
    bool flag = true;
    // Update is called once per frame
    void Update()
    {
        if (flag)
            GetComponent<Rigidbody>().velocity = Vector3.up*jumpForce;
        flag= false;
    }
}
