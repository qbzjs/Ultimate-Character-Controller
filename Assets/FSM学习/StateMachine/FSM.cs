using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//有限状态机脚本

//
public enum StateType
{
    Idle, Patrol, Chase, React, Attack, Hit, Death
}

//enemy的参数
[Serializable]
public class Parameter
{
    //
    public int health;
    //
    public float moveSpeed;
    //
    public float chaseSpeed;
    //
    public float idleTime;
    //
    public Transform[] patrolPoints;
    //
    public Transform[] chasePoints;
    //
    public Transform target;
    //
    public LayerMask targetLayer;
    //
    public Transform attackPoint;
    //
    public float attackArea;
    //
    public Animator animator;
    //
    public bool getHit;
}

//
public class FSM : MonoBehaviour
{
    //
    private IState currentState;
    //
    private Dictionary<StateType, IState> states = new Dictionary<StateType, IState>();
    //
    public Parameter parameter;

    //初始化状态机
    void Start()
    {
        states.Add(StateType.Idle, new IdleState(this));
        states.Add(StateType.Patrol, new PatrolState(this));
        states.Add(StateType.Chase, new ChaseState(this));
        states.Add(StateType.React, new ReactState(this));
        states.Add(StateType.Attack, new AttackState(this));
        states.Add(StateType.Hit, new HitState(this));
        states.Add(StateType.Death, new DeathState(this));

        TransitionState(StateType.Idle);

        parameter.animator = transform.GetComponent<Animator>();
    }

    //
    void Update()
    {
        currentState.OnUpdate();

        if (Input.GetKeyDown(KeyCode.Return))
        {
            parameter.getHit = true;
        }
    }
    //切换状态
    public void TransitionState(StateType type)
    {
        //先退出状态，然后再切换
        if (currentState != null) 
            currentState.OnExit();
        currentState = states[type];
        currentState.OnEnter();
    }

    //改变朝向
    public void FlipTo(Transform target)
    {
        if (target != null)
        {
            if (transform.position.x > target.position.x)
            {
                transform.localScale = new Vector3(-1, 1, 1);
            }
            else if (transform.position.x < target.position.x)
            {
                transform.localScale = new Vector3(1, 1, 1);
            }
        }
    }

    //
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            parameter.target = other.transform;
        }
    }

    //
    private void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            parameter.target = null;
        }
    }

    //
    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(parameter.attackPoint.position, parameter.attackArea);
    }
}