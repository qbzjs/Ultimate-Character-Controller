using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class PlayerStateMachine : StateMachine
{
    public PlayerState_Idle idleState;
    public PlayerState_Run runState;

    Animator animator;

    private void Awake()
    {
        animator = GetComponentInChildren<Animator>();
        idleState.Initialize(animator,this);
        runState.Initialize(animator, this);

        
    }

    private void Start()
    {
        SwitchOn(idleState);
    }
}
