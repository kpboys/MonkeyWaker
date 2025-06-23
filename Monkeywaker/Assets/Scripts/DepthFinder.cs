using System.IO;
using UnityEngine;

[ExecuteAlways]
public class DepthFinder : MonoBehaviour
{
	 [SerializeField]
	 private string savePath = "SaveImages";
	 [Space]
	 [SerializeField, HideInInspector]
	 private Material mat;
	 [SerializeField]
	 private int blurCount;
	 [SerializeField]
	 private float blurDistance;
	 [SerializeField]
	 private float gausAmplifier;

	 public bool bakeDepth;


	 public bool horizontalBool;
	 private static int _blurDistanceID = Shader.PropertyToID("_BlurDistance");
	 private static int _gausAmplifierID = Shader.PropertyToID("_GausAmplifier");
	 private static int _horizontalID = Shader.PropertyToID("_Horizontal");

	 public Material Mat 
	 {
		  get
		  {
				if(mat == null)
					 mat = new Material(Shader.Find("Water/GausTextureEffect"));
				return mat;
		  }
		  set => mat = value; 
	 }

	 void OnRenderImage(RenderTexture src, RenderTexture dest)
	 {
		  if(bakeDepth == false)
		  {
				Mat.SetFloat(_blurDistanceID, blurDistance);
				Mat.SetFloat(_gausAmplifierID, gausAmplifier);

				Mat.SetInt(_horizontalID, horizontalBool ? 1 : 0);
				Graphics.Blit(src, dest, Mat);

				Texture2D newDest = new Texture2D(dest.width, dest.height, TextureFormat.ARGB32, false);
				RenderTexture.active = dest;
				newDest.ReadPixels(new Rect(0, 0, dest.width, dest.height), 0, 0);
				newDest.Apply();

				for (int i = 0; i < blurCount * 2 + 1; i++)
				{
					 horizontalBool = !horizontalBool;
					 Mat.SetInt(_horizontalID, horizontalBool ? 1 : 0);
					 Graphics.Blit(newDest, dest, Mat);
					 newDest.ReadPixels(new Rect(0, 0, dest.width, dest.height), 0, 0);
					 newDest.Apply();
				}

				Texture2D saveToTex = new Texture2D(dest.width, dest.height, TextureFormat.ARGB32, false);
				RenderTexture.active = dest;
				saveToTex.ReadPixels(new Rect(0, 0, dest.width, dest.height), 0, 0);
				saveToTex.Apply();
				byte[] bytes = saveToTex.EncodeToPNG();
				var dirPath = Application.dataPath + "/../Assets/" + savePath + "/";
				if (!Directory.Exists(dirPath))
				{
					 Directory.CreateDirectory(dirPath);
				}
				File.WriteAllBytes(dirPath + dest.name + ".png", bytes);

				DestroyImmediate(newDest);
				DestroyImmediate(saveToTex);

				bakeDepth = true;
		  }
	 }
}
