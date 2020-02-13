using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordController : MonoBehaviour
{
    public Transform sword;
    public Material glowMaterial;
    public ParticleSystem swordVanish;

    public bool SwordActive { get; set; }

    private Transform swordHand;
    private Vector3 swordOrigRot;
    private Vector3 swordOrigPos;
    private MeshRenderer swordMesh;

    GameObject swordClone;
    MeshRenderer swordCloneMesh;
    // Start is called before the first frame update
    void Start() {
        swordHand = sword.parent;
        swordOrigRot = sword.localEulerAngles;
        swordOrigPos = sword.localPosition;
        swordMesh = sword.GetComponentInChildren<MeshRenderer>();
        swordMesh.enabled = false;
        SwordActive = false;
    }

    private void Update(){
        
    }

    void CloneSword() {
        if (swordClone == null)
        {
            swordClone = Instantiate(sword.gameObject, sword.position, sword.rotation, swordHand);

            swordCloneMesh = swordClone.GetComponentInChildren<MeshRenderer>();
            Material[] materials = swordCloneMesh.materials;
            for (int i = 0; i < materials.Length; i++)
            {
                Material m = glowMaterial;
                materials[i] = m;
            }
            swordCloneMesh.materials = materials;
        }
        else{
            swordClone.SetActive(true);
        }
    }

    public IEnumerator HideSword(){
        SwordActive = false;
        yield return new WaitForSeconds(2);
        if (SwordActive) yield break;
        CloneSword();
        foreach (Material mat in swordCloneMesh.materials){
            mat.SetFloat("_AlphaThreshold", 0);
            mat.DOFloat(2, "_AlphaThreshold", 2f).OnComplete(() => swordClone.SetActive(false));
        }
        swordMesh.enabled = false;
        swordVanish.Play();
    }
    //improve
    public void ShowSword(){
        if (swordMesh.enabled){
            SwordActive = true;
            return;
        }
        DOVirtual.Float(9, 0, 1, GlowSwordAmount);
        swordMesh.enabled = true;
        swordVanish.Play();
        SwordActive = true;
    }

    void GlowSwordAmount(float x){
        foreach (Material mat in swordMesh.materials)
        {
            mat.SetFloat("RimAmount", x);
        }
    }
    //improve rotation
    public void Throw(Transform target, float warpDuration){
        sword.parent = null;
        sword.DOMove(target.position, warpDuration / 1.2f);
        sword.DOLookAt(target.position, .2f, AxisConstraint.None);
    }

    public void Return(){
        sword.parent = swordHand;
        sword.localPosition = swordOrigPos;
        sword.localEulerAngles = swordOrigRot;
    }
}
