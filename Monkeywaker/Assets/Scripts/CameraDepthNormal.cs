using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraDepthNormal : MonoBehaviour
{
	 [SerializeField]
	 private DepthTextureMode mode;
	 private void OnEnable()
	 {
		  GetComponent<Camera>().depthTextureMode = mode;
	 }
}
