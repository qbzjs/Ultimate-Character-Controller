using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    Animator animator;

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }
}
