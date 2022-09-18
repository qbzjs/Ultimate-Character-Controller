using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class delegatetest : MonoBehaviour
{
    delegate void delegateExample(int a);
    private void Start()
    {
        fooBar(bar);
        fooBar(foo);
    }
    void fooBar(delegateExample mydelegate)
    {
        mydelegate(50);
    }

    void foo(int a)
    {
        Debug.Log("Foo");
    }
    void bar(int a)
    {
        Debug.Log("Bar");
    }
}
