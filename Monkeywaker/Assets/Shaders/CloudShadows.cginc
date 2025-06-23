//  These uniforms should be set globally from a script
sampler2D _CloudAlphaTex;    //   type: Texture       defalut: (1,1,1,1) 
float4 _CloudAlphaTex_ST;
float _CloudSpeed;           //   type: float         defalut: 20 
float _CloudDirection;       //   type: Range(0,360)  defalut: 0 
float _CloudShadowIntensity; //   type: Range(0,2)    defalut: 1
float4 _CloudSmoothStep;
float _TimeOffset;


//todo write a comment
inline fixed CalculateCloudShadowMask (v2f i)
{
    //Note from Peter: 
    //Offset for _Time so we can control where in the pattern we should start
    //Flipped cos and sin and made them negative. This now matches how we decide direction
    //for the wind of grass and leaves.
    float offsetTime = _Time.x + _TimeOffset;
    float2 cloudUV = float2(
        (i.worldPos.x + (-1 * cos(radians(_CloudDirection))) * offsetTime * _CloudSpeed) / _CloudAlphaTex_ST.x + i.worldPos.y * _WorldSpaceLightPos0.x / _CloudAlphaTex_ST.x, 
        (i.worldPos.z + (-1 * sin(radians(_CloudDirection))) * offsetTime * _CloudSpeed) / _CloudAlphaTex_ST.y + i.worldPos.y * _WorldSpaceLightPos0.y / _CloudAlphaTex_ST.x
        );
    
    //Note from Peter:
    //Added a smoothstep to make the clouds clump up more and not be so "wispy"
    // fixed cloudShadowMask = 1- tex2D(_CloudAlphaTex, cloudUV) * _CloudShadowIntensity;
    fixed cloudShadowMask = smoothstep(_CloudSmoothStep.x,_CloudSmoothStep.y, 1-tex2D(_CloudAlphaTex, cloudUV));
    cloudShadowMask = 1 - (1 - cloudShadowMask) * SHADOW_ATTENUATION(i) * _CloudShadowIntensity;
    return cloudShadowMask;
}

//todo write a comment
#define CLOUD_SHADOW_MASK(a) CalculateCloudShadowMask(a)