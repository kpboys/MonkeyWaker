using UnityEngine;

[ExecuteAlways]
public class WorldCloudsHandler : MonoBehaviour
{
    [SerializeField]
    private Texture cloudTexture;
    private static int cloudTextureId = Shader.PropertyToID("_CloudAlphaTex");

    [SerializeField]
    private Vector3 tiling;

    [SerializeField]
    private Vector2 offset;

    [SerializeField, Space]
    private float cloudSpeed = 10f;
    private static int cloudSpeedId = Shader.PropertyToID("_CloudSpeed");

    [SerializeField, Range(0, 360)]
    private float cloudDirection = 0;
    private static int cloudDirectionId = Shader.PropertyToID("_CloudDirection");

    [SerializeField, Range(0, 2)]
    private float cloudShadowIntensity = 0.5f;
    private static int cloudShadowIntensityId = Shader.PropertyToID("_CloudShadowIntensity");

	 [SerializeField]
	 private float timeOffset = 0.0f;
	 private static int timeOffsetId = Shader.PropertyToID("_TimeOffset");

	 [SerializeField]
	 private Vector2 cloudSmoothStepRange = new Vector2(0.9f, 1.0f);
	 private static int cloudSmoothStepId = Shader.PropertyToID("_CloudSmoothStep");


	 [Button(nameof(UpdateMaterials))]
    public bool updateMaterials_btn;

    [SerializeField, Space]
    private Material[] materials;



    private void OnDisable()
    {
        foreach (Material mat in materials)
        {
            if (mat != null)
            {
                mat.SetFloat(cloudShadowIntensityId, 0);
            }
        }
    }

    public void UpdateMaterials()
    {
		  foreach (Material mat in materials)
		  {
				if (mat != null)
				{
					 mat.SetTexture(cloudTextureId, cloudTexture);
					 mat.SetTextureScale(cloudTextureId, tiling);
					 mat.SetTextureOffset(cloudTextureId, offset);
					 mat.SetFloat(cloudSpeedId, cloudSpeed);
					 mat.SetFloat(cloudDirectionId, cloudDirection);
					 mat.SetFloat(cloudShadowIntensityId, cloudShadowIntensity);
					 mat.SetFloat(timeOffsetId, timeOffset);
					 mat.SetVector(cloudSmoothStepId, new Vector4(cloudSmoothStepRange.x, cloudSmoothStepRange.y, 0, 0));
				}
		  }
	 }
	 private void Awake()
	 {
		  UpdateMaterials();
	 }

	 //private void Awake()
	 //{
	 //    foreach (Material mat in materials)
	 //    {
	 //        if (mat != null)
	 //        {
	 //            mat.SetTexture(cloudTextureId, cloudTexture);
	 //            mat.SetTextureScale(cloudTextureId, tiling);
	 //            mat.SetTextureOffset(cloudTextureId, offset);
	 //        }
	 //    }
	 //}

	 //private void Update()
	 //{
	 //    foreach (Material mat in materials)
	 //    {
	 //        if (mat != null)
	 //        {
	 //            mat.SetFloat(cloudSpeedId, cloudSpeed);
	 //            mat.SetFloat(cloudDirectionId, cloudDirection);
	 //            mat.SetFloat(cloudShadowIntensityId, cloudShadowIntensity);
	 //        }
	 //    }
	 //}
}
