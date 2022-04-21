using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
public class PlayerController : MonoBehaviour
{
    Animator animator;

    private void Awake()
    {
        animator = GetComponentInChildren<Animator>();

    }

    //private void Update()
    //{
    //    if(Keyboard.current.aKey.isPressed || Keyboard.current.dKey.isPressed)
    //    {
    //        animator.Play("Run");
    //    }
    //    else
    //    {
    //        animator.Play("Idle");
    //    }
    //}


}
