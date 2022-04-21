using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
[CreateAssetMenu(menuName ="Data/StateMachine/PlayerState/Idle", fileName ="PlayerState_Idle")]
public class PlayerState_Idle : PlayerState
{
    public override void Enter()
    {
        animator.Play("Idle");
    }

    public override void Logicupdate()
    {
        if (Keyboard.current.aKey.isPressed || Keyboard.current.dKey.isPressed)
        {
            stateMachine.SwitchState(stateMachine.runState);
        }
        
    }
}
