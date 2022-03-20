using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StuForeach : MonoBehaviour
{
    
    int cupsInTheSink = 4;
    // Start is called before the first frame update
    void Start()
    {
        while(cupsInTheSink>0)
        {
            Debug.Log("hhh");
            cupsInTheSink--;
        }
    }

    // Update is called once per frame
  
}
