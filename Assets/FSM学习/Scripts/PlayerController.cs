using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [Header("补偿速度")]
    public float lightSpeed;
    public float heavySpeed;
    [Header("打击感")]
    public float shakeTime;
    public int lightPause;
    public float lightStrength;
    public int heavyPause;
    public float heavyStrength;

    [Space]
    public float interval = 2f;
    private float timer;
    private bool isAttack;
    private string attackType;
    private int comboStep;

    public float moveSpeed;
    public float jumpForce;
    new private Rigidbody2D rigidbody;
    private Animator animator;
    private float input;
    private bool isGround;
    [SerializeField] private LayerMask layer;

    [SerializeField] private Vector3 check;

    void Start()
    {
        rigidbody = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        input = Input.GetAxisRaw("Horizontal");
        isGround = Physics2D.OverlapCircle(transform.position + new Vector3(check.x, check.y, 0), check.z, layer);

        animator.SetFloat("Horizontal", rigidbody.velocity.x);
        animator.SetFloat("Vertical", rigidbody.velocity.y);
        animator.SetBool("isGround", isGround);

        Move();
        Attack();
    }

    void Move()
    {
        if (!isAttack)
            rigidbody.velocity = new Vector2(input * moveSpeed, rigidbody.velocity.y);
        else
        {
            if (attackType == "Light")
                rigidbody.velocity = new Vector2(transform.localScale.x * lightSpeed, rigidbody.velocity.y);
            else if (attackType == "Heavy")
                rigidbody.velocity = new Vector2(transform.localScale.x * heavySpeed, rigidbody.velocity.y);
        }

        if (Input.GetButtonDown("Jump") && isGround)
        {
            rigidbody.velocity = new Vector2(0, jumpForce);
            animator.SetTrigger("Jump");
        }

        if (rigidbody.velocity.x < 0)
            transform.localScale = new Vector3(-1, 1, 1);
        else if (rigidbody.velocity.x > 0)
            transform.localScale = new Vector3(1, 1, 1);
    }

    void Attack()
    {
        if (Input.GetKeyDown(KeyCode.Return) && !isAttack)
        {
            isAttack = true;
            attackType = "Light";
            comboStep++;
            if (comboStep > 3)
                comboStep = 1;
            timer = interval;
            animator.SetTrigger("LightAttack");
            animator.SetInteger("ComboStep", comboStep);
        }
        if (Input.GetKeyDown(KeyCode.RightShift) && !isAttack)
        {
            isAttack = true;
            attackType = "Heavy";
            comboStep++;
            if (comboStep > 3)
                comboStep = 1;
            timer = interval;
            animator.SetTrigger("HeavyAttack");
            animator.SetInteger("ComboStep", comboStep);
        }


        if (timer != 0)
        {
            timer -= Time.deltaTime;
            if (timer <= 0)
            {
                timer = 0;
                comboStep = 0;
            }
        }
    }

    public void AttackOver()
    {
        isAttack = false;
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Enemy"))
        {
            if (attackType == "Light")
            {
                AttackSense.Instance.HitPause(lightPause);
                AttackSense.Instance.CameraShake(shakeTime, lightStrength);
            }
            else if (attackType == "Heavy")
            {
                AttackSense.Instance.HitPause(heavyPause);
                AttackSense.Instance.CameraShake(shakeTime, heavyStrength);
            }

            if (transform.localScale.x > 0)
                other.GetComponent<Enemy>().GetHit(Vector2.right);
            else if (transform.localScale.x < 0)
                other.GetComponent<Enemy>().GetHit(Vector2.left);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position + new Vector3(check.x, check.y, 0), check.z);
    }
}