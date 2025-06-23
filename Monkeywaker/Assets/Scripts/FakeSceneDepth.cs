using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class FakeSceneDepth : MonoBehaviour
{
	 [SerializeField, HideInInspector]
	 private Material mat;

	 public Material Mat
	 {
		  get
		  {
				if (mat == null)
					 mat = new Material(Shader.Find("Custom/FakeSceneDepth"));
				return mat;
		  }
		  set => mat = value;
	 }
	 private void OnRenderImage(RenderTexture source, RenderTexture destination)
	 {
		  Graphics.Blit(source, destination, Mat);
	 }
}
