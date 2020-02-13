using Cinemachine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BladeMode : MonoBehaviour
{

    public bool bladeMode;
    public CinemachineFreeLook TPCamera;
    public Transform cutPlane;
    private Animator anim;
    private MoveController movement;
    private SwordController swordControl;
    // Start is called before the first frame update
    void Start() {
        anim = this.GetComponent<Animator>();
        movement = this.GetComponent<MoveController>();
        swordControl = this.GetComponent<SwordController>();
        cutPlane.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update(){
        if (Input.GetButtonDown("Fire3") && !bladeMode){
            swordControl.ShowSword();
            SetMode(true);
        }
        else if (Input.GetButtonDown("Fire3") && bladeMode){
            StartCoroutine(swordControl.HideSword());
            SetMode(false);
        }
        if (bladeMode){
            Quaternion forward = Camera.main.transform.rotation;
            forward.x = forward.z = 0;
            transform.rotation = Quaternion.Lerp(transform.rotation, forward, .2f);
            RotateCutPlane();
            anim.SetFloat("x", Mathf.Clamp(cutPlane.localPosition.x + 0.3f, -1, 1));
            anim.SetFloat("y", Mathf.Clamp(cutPlane.localPosition.y + .18f, -1, 1));
        }
    }

    void SetMode(bool state){
        bladeMode = state;
        anim.SetBool("bladeMode", state);
        movement.canMove = !state;
        float to = state ? 20 : 40;
        float timeScale = state ? .5f : 1;
        DOVirtual.Float(TPCamera.m_Lens.FieldOfView, to, 1, FieldOfView);
        DOVirtual.Float(Time.timeScale, timeScale, .02f, SetTimeScale);

        cutPlane.localEulerAngles = Vector3.right * cutPlane.localEulerAngles.x;
        cutPlane.gameObject.SetActive(state);

        string x = state ? "Horizontal" : "Mouse X";
        string y = state ? "Vertical" : "Mouse Y";
        TPCamera.m_XAxis.m_InputAxisName = x;
        TPCamera.m_YAxis.m_InputAxisName = y;

        if (state){
            /*Vector3 forward = Camera.main.transform.forward;
            forward.y = 0;
            transform.rotation = Quaternion.LookRotation(forward);*/
            DOVirtual.Float(TPCamera.m_YAxis.Value, 0.5f, 0.5f, AxisY);
        }
    }

    void AxisY(float x){
        TPCamera.m_YAxis.Value = x;
    }

    void FieldOfView(float x){
        TPCamera.m_Lens.FieldOfView = x;
    }

    void SetTimeScale(float time) {
        Time.timeScale = time;
    }

    public void RotateCutPlane() {
        cutPlane.eulerAngles += new Vector3(0, 0, -Input.GetAxis("Mouse X") * 5);
    }
}
