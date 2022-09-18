using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class actiontest : MonoBehaviour
{
    public delegate void delegatepPrintInt(int x);
    public delegate int delegatepAddInt(int a,int b);

    // Update is called once per frame
    void Update()
    {
        delegatepPrintInt delegatepPrintInt = printInt;
        delegatepAddInt delegatepAddInt = addInt;
        int x = 0;
        x = delegatepAddInt(x, 1);
        delegatepPrintInt(x);
        
    }

    void printInt(int x)
    {
        Debug.Log(x);
    }

    int addInt(int a,int b)
    {
        a = a + b;
        return a;
    }
}
