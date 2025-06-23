using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class WorldWindHandler : MonoBehaviour
{

    [SerializeField, Space]
    [Range(0, 1)]
    public float windIntensity = 0;
    private float intensity = 0;

    private static int windSpeedId = Shader.PropertyToID("_WindSpeed");
    private static int windStrengthId = Shader.PropertyToID("_WindStrength");
    private static int swayPositionId = Shader.PropertyToID("_SwayPosition");
    private static int windNoiseId = Shader.PropertyToID("_NoiseSpread");
    private static int exponentId = Shader.PropertyToID("_WindExponent");
    private static int constantId = Shader.PropertyToID("_WindExponentConstant");

    [SerializeField, Range(0, 360)]
    private float windDirection = 0;
    private float direction = 0;
    private static int windDirectionId = Shader.PropertyToID("_WindDirection");

    [SerializeField, Space]
    private Material[] materials;

    private void OnDisable()
    {
        foreach (Material mat in materials)
        {
            if (mat != null)
            {
                mat.SetFloat(windSpeedId, 0);
                mat.SetFloat(windStrengthId, 0);
            }
        }
    }

    private void Update()
    {
        if (intensity != windIntensity || direction != windDirection)
        {
            intensity = windIntensity;
            direction = windDirection;
            UpdateMaterials();
        }
    }

    private void UpdateMaterials()
    {
        float strength = Mathf.Lerp(0.1f, 0.16f, intensity);
        float speed = Mathf.Lerp(0.4f, 6.61f, intensity);
        float noise = Mathf.Lerp(8, 30, intensity);
        float position = Mathf.Lerp(0, 0.66f, intensity);
        float expo = Mathf.Lerp(1.1f, 1.3f, intensity);
        float con = Mathf.Lerp(1, 10, intensity);
        foreach (Material mat in materials)
        {
            if (mat != null)
            {
                mat.SetFloat(windStrengthId, strength);
                mat.SetFloat(windSpeedId, speed);
                mat.SetFloat(windNoiseId, noise);
                mat.SetFloat(swayPositionId, position);
                mat.SetFloat(exponentId, expo);
                mat.SetFloat(constantId, con);
                mat.SetFloat(windDirectionId, windDirection);
            }
        }
    }


}
