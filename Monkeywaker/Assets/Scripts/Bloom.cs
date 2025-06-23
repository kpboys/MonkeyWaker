using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.PostProcessing;
using BoolParameter = UnityEngine.Rendering.PostProcessing.BoolParameter;
using FloatParameter = UnityEngine.Rendering.PostProcessing.FloatParameter;
using IntParameter = UnityEngine.Rendering.PostProcessing.IntParameter;
using ColorParameter = UnityEngine.Rendering.PostProcessing.ColorParameter;
using TextureParameter = UnityEngine.Rendering.PostProcessing.TextureParameter;

[Serializable]
[PostProcess(typeof(BloomRenderer), PostProcessEvent.AfterStack, "Custom/Bloom")]
public sealed class Bloom : PostProcessEffectSettings
{
    [Range(0, 5), Tooltip("Threshold for brightness")]
    public FloatParameter threshold = new FloatParameter { value = 1 };

    [Range(0.0001f, 0.05f), Tooltip("Amount of blur")]
    public FloatParameter blurAmount = new FloatParameter { value = 0.003f };

    [Range(1, 100), Tooltip("How many blits for making the blur")]
    public IntParameter blurCount = new IntParameter { value = 10 };

    public ColorParameter underlayColor = new ColorParameter() { value = Color.red };
    public TextureParameter fakeDepthTexture = new TextureParameter() { value = null };

}

public sealed class BloomRenderer : PostProcessEffectRenderer<Bloom>
{
    private List<int> tempRTs;

    private CommandBuffer commandBuffer;
    private Shader bloomShader;
    private PropertySheet bloomSheet;

    public override void Render(PostProcessRenderContext context)
    {
        tempRTs = new List<int>();
        commandBuffer = context.command;

        bloomShader = Shader.Find("Hidden/Custom/Bloom");
        bloomSheet = context.propertySheets.Get(bloomShader);
        Shader gaussShader = Shader.Find("Hidden/Custom/BloomGauss");
        PropertySheet gaussSheet = context.propertySheets.Get(gaussShader);

        bloomSheet.properties.SetFloat("_Threshold", settings.threshold);
        commandBuffer.SetGlobalTexture("_SourceTex", context.source);
        gaussSheet.properties.SetFloat("_BlurAmount", settings.blurAmount);

        bloomSheet.properties.SetColor("_UnderlayCol", settings.underlayColor);
        if (settings.fakeDepthTexture.value != null)
            bloomSheet.properties.SetTexture("_FakeDepthTexture", settings.fakeDepthTexture);


        #region Brightness Isolation
        int brightTemp = GetTemp(123, context);
        commandBuffer.BlitFullscreenTriangle(context.source, brightTemp, bloomSheet, 0);
        #endregion

        #region Gaussian blur
        bool currentPass = true;
        int tID = 5000;
        int temp = GetTemp(tID++, context);
        commandBuffer.BlitFullscreenTriangle(brightTemp, temp, gaussSheet, currentPass ? 1 : 0);
        int currentActive = temp;
        for (int i = 0; i < settings.blurCount; i++)
        {
            temp = GetTemp(tID + i, context);
            commandBuffer.BlitFullscreenTriangle(currentActive, temp, gaussSheet, currentPass ? 1 : 0);
            currentPass = !currentPass;
            currentActive = temp;
        }
        int blurredTemp = currentActive;
        #endregion

        #region Combine
        int combinedTemp = GetTemp(565, context);
        commandBuffer.BlitFullscreenTriangle(blurredTemp, combinedTemp, bloomSheet, 1);
        #endregion

        //Final blit
        commandBuffer.BlitFullscreenTriangle(combinedTemp, context.destination);

        ReleaseRTs();
    }

    private int GetTemp(int id, PostProcessRenderContext context, int depthBuffer = 0)
    {
        context.command.GetTemporaryRT(id, context.width, context.height, depthBuffer);
        if (tempRTs.Contains(id)) { Debug.LogError("Id already excists!"); }
        tempRTs.Add(id);
        return id;
    }

    private void ReleaseRTs()
    {
        foreach (int rt in tempRTs)
        {
            commandBuffer.ReleaseTemporaryRT(rt);
        }
    }

}