using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StuIF : MonoBehaviour
{
    float coffee = 85.0f;
    float hot = 70.0f;
    float cold = 40.0f;

    // Start is called before the first frame update
    

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
            check();
        coffee = Time.deltaTime * 5f;
    }

    void check()
    {
        if(coffee >hot)
        {
            //print("its hot!!");
            Debug.Log("its hot!!");
        }
        else if(coffee <=cold)
        {
            //print("its cold now!!!");
            Debug.Log("its cold now!!!");
        }
    }
}
