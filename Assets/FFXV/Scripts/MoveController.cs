using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class MoveController : MonoBehaviour
{
    public float velocity = 9;
    [Space]
    public float allowPlayerRotation = 0.1f;
    public float desiredRotationSpeed = 0.1f;
    public bool blockRotationPlayer;
    public bool canMove;
    public bool onlyWalk;

    float InputX;
    float InputZ;
    float Speed;
    Vector3 desiredMoveDirection;
    bool isGrounded;

    Animator anim;
    Camera cam;
    CharacterController controller;
    // Start is called before the first frame update
    void Start()
    {
        anim = this.GetComponent<Animator>();
        cam = Camera.main;
        controller = this.GetComponent<CharacterController>();
        onlyWalk = false;
    }

    // Update is called once per frame
    void Update() {
        if (!canMove)
            return;
        InputMagnitude();
    }

    void InputMagnitude() {
        //Calculate Input Vectors
        InputX = Input.GetAxis("Horizontal");
        InputZ = Input.GetAxis("Vertical");

        //anim.SetFloat ("InputZ", InputZ, VerticalAnimTime, Time.deltaTime * 2f);
        //anim.SetFloat ("InputX", InputX, HorizontalAnimSmoothTime, Time.deltaTime * 2f);

        //Calculate the Input Magnitude
        if (onlyWalk){
            InputX = Mathf.Clamp(InputX, -0.5f, 0.5f);
            InputZ = Mathf.Clamp(InputZ, -0.5f, 0.5f);
        }
        Speed = new Vector2(InputX, InputZ).sqrMagnitude;
        
        anim.SetFloat("velocity", Speed);
        //Physically move player
        if (Speed > allowPlayerRotation){
            //anim.SetFloat ("InputMagnitude", Speed, StartAnimTime, Time.deltaTime);
            PlayerMoveAndRotation();
        }
        else if (Speed < allowPlayerRotation) {
            //anim.SetFloat ("InputMagnitude", Speed, StopAnimTime, Time.deltaTime);
        }
    }

    void PlayerMoveAndRotation(){
        Vector3 forward = cam.transform.forward;
        Vector3 right = cam.transform.right;

        forward.y = 0f;
        right.y = 0f;

        forward.Normalize();
        right.Normalize();

        desiredMoveDirection = forward * InputZ + right * InputX;

        if (blockRotationPlayer == false)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(desiredMoveDirection), desiredRotationSpeed);
            controller.Move(desiredMoveDirection * Time.deltaTime * velocity);
        }
    }

    public void RotateTowards(Transform target){
        transform.rotation = Quaternion.LookRotation(target.position - transform.position);
    }
}
