using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerState : ScriptableObject, IState
{
    Animator animatior;
    PlayerStateMachine stateMachine;
    
    public void Initialize(Animator animator,PlayerStateMachine stateMachine)
    {
        this.animatior = animatior;
        this.stateMachine = stateMachine;
    }

    public virtual void Enter()
    {
        
    }

    public virtual void Exit()
    {
        
    }

    public virtual void Logicupdate()
    {
        
    }

    public virtual void PhysicUpdate()
    {
        
    }
}
