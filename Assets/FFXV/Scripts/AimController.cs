using Cinemachine;
using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AimController : MonoBehaviour
{
    public List<Transform> screenTargets = new List<Transform>();
    public Transform target;
    public CinemachineTargetGroup objective;
    [Header("Canvas")]
    public Image aim;
    public Image lockAim;
    public Vector2 uiOffset;

    public bool isLocked { get; set; }
    void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }
    private void Update() {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.visible = false;
        }

        UserInterface();
        if (screenTargets.Count < 1){
            target = null;
            objective.m_Targets[1].target = null;
            return;
        }
        if (!isLocked){
            target = screenTargets[nearestTarget()];
        }

        if (Input.GetButtonDown("Fire2")) {
            LockInterface(!isLocked);
        }
    }

    public void LockInterface(bool state){
        isLocked = state;
        float size = state ? 1 : 2;
        float fade = state ? 1 : 0;
        lockAim.DOFade(fade, .15f);
        lockAim.transform.DOScale(size, .15f).SetEase(Ease.OutBack);
        lockAim.transform.DORotate(Vector3.forward * 180, .15f, RotateMode.FastBeyond360).From();
        aim.transform.DORotate(Vector3.forward * 90, .15f, RotateMode.LocalAxisAdd);
        if(!state) aim.DOFade(0, 0.5f);

        objective.m_Targets[1].target = state ? target : null ;
    }

    private void UserInterface(){
        Color c = screenTargets.Count < 1 ? Color.clear : Color.white;
        aim.DOFade( c.a, 0.5f);
        if (target != null)
            aim.transform.position = Camera.main.WorldToScreenPoint(target.position + (Vector3)uiOffset);
    }

    int nearestTarget() {
        float[] distances = new float[screenTargets.Count];
        Dictionary<float, int> distancesIndex = new Dictionary<float, int>();
        for (int i = 0; i < screenTargets.Count; i++){
            distances[i] = Vector2.Distance(Camera.main.WorldToScreenPoint(screenTargets[i].position), new Vector2(Screen.width / 2, Screen.height / 2));
            distancesIndex.Add(distances[i], i);
        }
        float minDistance = Mathf.Min(distances);
        return distancesIndex[minDistance];
    }
}
