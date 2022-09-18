using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class V2 : MonoBehaviour
{
    public void Start()
    {
        Debug.Log("��̬����");
        //
        Debug.Log(Vector2.zero);
        Debug.Log(Vector2.one);
        Debug.Log(Vector2.left);
        Debug.Log(Vector2.right);
        Debug.Log(Vector2.up);
        Debug.Log(Vector2.down);

        //
        Debug.Log(Vector2.negativeInfinity);
        Debug.Log(Vector2.positiveInfinity);

        Debug.Log("����, v2Ϊ(2,2)");
        Vector2 v2 = Vector2.zero;
        v2.x = 2f;
        v2.y = 2f;
        //
        Debug.Log(v2[0]);
        Debug.Log(v2[1]);
        Debug.Log(v2.sqrMagnitude);
        Debug.Log(v2.magnitude);
        //
        Vector2 temp = v2;
        //Debug.Log(temp);
        //Debug.Log(temp.normalized);
        //Debug.Log(temp);

        Debug.Log("public ����");
        bool res = Vector2.Equals(v2, temp);
        Debug.Log(res);
        temp.Normalize();
        Debug.Log(temp);

        Debug.Log("Static ����");
        temp = Vector2.left;
        Debug.Log(Vector2.Angle(v2, temp));
        Debug.Log(Vector2.Distance(v2, temp));
        Debug.Log(Vector2.ClampMagnitude(v2, 3));
        Debug.Log(Vector2.Lerp(v2, temp, 0.2f));
        Debug.Log(Vector2.LerpUnclamped(v2, temp, 0));

        Debug.Log("move to wards");
        temp.x = 2f;
        temp.y = 4f;
        v2 = Vector2.MoveTowards(v2, temp, 1f);
        Debug.Log(v2);
        v2 = Vector2.MoveTowards(v2, temp, 1f);
        Debug.Log(v2);
        v2 = Vector2.MoveTowards(v2, temp, 0.1f);
        Debug.Log(v2); 
        v2 = Vector2.MoveTowards(v2, temp, 0.1f);
        Debug.Log(v2); 
        v2 = Vector2.MoveTowards(v2, temp, 0.1f);
        Debug.Log(v2);
    }
}