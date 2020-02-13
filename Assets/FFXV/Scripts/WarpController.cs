using Cinemachine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class WarpController : MonoBehaviour
{
    //public List<Transform> screenTargets = new List<Transform>();
    //public Transform target;
    public float warpDuration = .5f;
    public Material glowMaterial;
    [Space]
    [Header("Particles")]
    public ParticleSystem trail;
    public ParticleSystem whiteTrail;

    private CinemachineImpulseSource impulse;
    LensDistortion distorsion;

    MoveController input;
    AimController aimControl;
    SwordController swordControl;
    Animator anim;
    SkinnedMeshRenderer[] skinMeshList;

    GameObject clone;
    SkinnedMeshRenderer[] skinMeshListClone;
    // Start is called before the first frame update
    void Start()
    {
        anim = this.GetComponent<Animator>();
        input = this.GetComponent<MoveController>();
        aimControl = this.GetComponent<AimController>();
        swordControl = this.GetComponent<SwordController>();
        skinMeshList = GetComponentsInChildren<SkinnedMeshRenderer>();

        impulse = FindObjectOfType<CinemachineFreeLook>().GetComponent<CinemachineImpulseSource>();
        Volume postVolume = FindObjectOfType<Volume>();
        VolumeProfile postProfile = postVolume.profile;
        postProfile.TryGet<LensDistortion>(out distorsion);
    }

    // Update is called once per frame
    void Update()
    {
        if (!input.canMove || aimControl.target == null) return;
        if (Input.GetButtonDown("Fire1")){
            swordControl.ShowSword();
            anim.SetTrigger("slash");
            input.canMove = false;
            aimControl.LockInterface(true);
            input.RotateTowards(aimControl.target);
        }
    }

    void Warp() {
        CloneBody();
        ShowBody(false);
        anim.speed = 0;
        transform.DOMove(aimControl.target.position, warpDuration).SetEase(Ease.InExpo).OnComplete(() => FinishWarp());
        swordControl.Throw(aimControl.target, warpDuration);

        trail.Play();
        whiteTrail.Play();

        //Lens Distortion
        DOVirtual.Float(0, -0.8f, .2f, DistortionAmount);
        DOVirtual.Float(1, 2, .2f, ScaleAmount);
    }

    void FinishWarp() {
        ShowBody(true);
        swordControl.Return();
        aimControl.LockInterface(false);
        impulse.GenerateImpulse(Vector3.right);
        StartCoroutine(swordControl.HideSword());
        StartCoroutine(Animations());
        DOVirtual.Float(9, 0, 5, GlowAmount);

        //Lens Distortion
        DOVirtual.Float(-0.8f, 0, .2f, DistortionAmount);
        DOVirtual.Float(2, 1, .2f, ScaleAmount);

    }

    void ShowBody(bool state) {
        foreach (SkinnedMeshRenderer smr in skinMeshList){
            smr.enabled = state;
        }
    }

    IEnumerator Animations()
    {
        yield return new WaitForSeconds(.2f);
        trail.Stop();
        whiteTrail.Stop();
        anim.speed = 1;
        yield return new WaitForSeconds(.8f);
        input.canMove = true;
    }

    void GlowAmount(float x) {
        foreach (SkinnedMeshRenderer smr in skinMeshList){
            smr.material.SetFloat("RimAmount", x);
        }
    }

    void DistortionAmount(float x) {
        distorsion.intensity.value = x;
    }
    void ScaleAmount(float x)
    {
        distorsion.scale.value = x;
    }

    void CloneBody() {
        if (clone == null)
        {
            clone = Instantiate(gameObject, transform.position, transform.rotation);
            Destroy(clone.GetComponent<SwordController>().sword.gameObject);
            Destroy(clone.GetComponent<Animator>());
            Destroy(clone.GetComponent<WarpController>());
            Destroy(clone.GetComponent<SwordController>());
            Destroy(clone.GetComponent<MoveController>());
            Destroy(clone.GetComponent<CharacterController>());

            skinMeshListClone = clone.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (SkinnedMeshRenderer smr in skinMeshListClone)
            {
                smr.material = glowMaterial;
                smr.material.SetFloat("_AlphaThreshold", 0);
                smr.material.DOFloat(2, "_AlphaThreshold", 1f).OnComplete(() => clone.SetActive(false));
            }
        }
        else {
            clone.SetActive(true);
            clone.transform.position = transform.position;
            clone.transform.rotation = transform.rotation;
            foreach (SkinnedMeshRenderer smr in skinMeshListClone)
            {
                smr.material.SetFloat("_AlphaThreshold", 0);
                smr.material.DOFloat(2, "_AlphaThreshold", 1f).OnComplete(() => clone.SetActive(false));
            }
        }
    }
}
