using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;
[CreateAssetMenu(menuName = "Player Input")]
public class InputManager : ScriptableObject, MyInputAction.IRoleActions
{
    //
    MyInputAction m_Action;


    private void OnEnable()
    {
        //
        m_Action=new MyInputAction();
        //
        m_Action.Role.SetCallbacks(this);
    }
    private void OnDisable()
    {
        disableRoleInput();
    }

    #region
    public void enableRoleInput()
    {
        m_Action.Role.Enable();
    }


    public void disableRoleInput()
    {
        m_Action.Role.Disable();
    }
    #endregion


    public event UnityAction<Vector2> onMoveEvent = delegate { };
    public event UnityAction onStopMoveEvent=delegate { };
    Vector3 m_Position;
    public void OnMove(InputAction.CallbackContext context)
    {
        //throw new System.NotImplementedException();
        if(context.phase==InputActionPhase.Performed)
        {

            onMoveEvent.Invoke(context.ReadValue<Vector2>());
            //m_Position = context.ReadValue<Vector2>();
            //m_Position.z = m_Position.y;
            //m_Position.y = 0;
            //onMoveEvent.Invoke(m_Position);
        }

        if(context.phase==InputActionPhase.Canceled)
        {
            onStopMoveEvent.Invoke();
        }
    }
}
