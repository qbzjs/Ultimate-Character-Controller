using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Player : MonoBehaviour
{
    [SerializeField]InputManager inputManager;
    new Rigidbody rigidbody;

    private void Awake()
    {
        rigidbody = GetComponent<Rigidbody>();
    }

    private void Start()
    {
        rigidbody.useGravity = false;
        inputManager.enableRoleInput();

        inputManager.onMoveEvent += MoveFunc;
        inputManager.onStopMoveEvent += StopMoveFunc;

    }
    #region
    [SerializeField] float movespeed = 10f;
    //�Ӽ���ʱ��
    //[SerializeField] float accTime=0.25f;
    //[SerializeField] float decelerdTime=0.25f;
    float accTime = 0.25f;
    float decelerdTime = 0.25f;
    
    //�ƶ��߼�Ҫ�õ�����ʱЭ��
    Coroutine TempCoMove;
    void MoveFunc(Vector2 moveinput)
    {
        //Vector2 moveAmount = moveinput.normalized * movespeed;
        //rigidbody.velocity = moveinput.normalized * movespeed;

        if (TempCoMove != null)
        {
            StopCoroutine(TempCoMove);
        }
        
        TempCoMove = StartCoroutine(Co_Move(moveinput.normalized * movespeed, accTime));
        
    }

    void StopMoveFunc()
    {

        if (TempCoMove != null)
        {
            StopCoroutine(TempCoMove);
        }

        TempCoMove = StartCoroutine(Co_Move(Vector2.zero, decelerdTime));
        
    }

    //�ƶ�Э��
    IEnumerator Co_Move(Vector2 moveVelocity, float type)
    {
        float time = 0f;
        
        while (time < type)
        {

            time += Time.fixedDeltaTime / type;
            //�Ӽ���
            rigidbody.velocity = Vector3.Lerp(rigidbody.velocity, moveVelocity, time / type);

            yield return null;
        }

    }


   

#endregion
}
