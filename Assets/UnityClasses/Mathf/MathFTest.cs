using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MathFTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        float a = 2, b = 10, res = 0;
        for (int i = 0; i < 10; i++)
        {
            res = Mathf.PingPong(a, b);
            Debug.Log(res);
        }
       
    }

}
