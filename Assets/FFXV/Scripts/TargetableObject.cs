using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetableObject : MonoBehaviour
{
    AimController aim;
    // Start is called before the first frame update
    void Start()
    {
        aim = FindObjectOfType<AimController>();
    }

    private void OnBecameVisible()
    {
        if (!aim.screenTargets.Contains(transform))
            aim.screenTargets.Add(transform);
    }

    private void OnBecameInvisible(){
        if (aim.screenTargets.Contains(transform))
            aim.screenTargets.Remove(transform);
    }
}
