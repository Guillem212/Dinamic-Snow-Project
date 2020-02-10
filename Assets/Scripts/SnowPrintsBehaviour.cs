using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnowPrintsBehaviour : MonoBehaviour
{

    [Range(0.01f, 1f)]
    public float objectSize;

    [Range(0.01f, 1f)]
    public float objectMass;

    [Range(0.01f, 1f)]
    public float objectDistanceToGround;
}
