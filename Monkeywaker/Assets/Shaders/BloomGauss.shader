Shader "Hidden/Custom/BloomGauss"
{
    HLSLINCLUDE
    // StdLib.hlsl holds pre-configured vertex shaders (VertDefault)
    // varying structs (VaryingsDefault), and most of the data you need to write common effects.
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

    float _BlurAmount;
    static const float _GausValues[5] = {
        0.227027,
        0.1945946,
        0.1216216,
        0.054054,
        0.016216
    };
    ENDHLSL
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment Horizontal

            float4 Horizontal(VaryingsDefault i) : SV_TARGET
            {
                float4 initSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                if (all(initSample == float4(0, 0, 0, 1)))
                    return initSample;
                float4 result = initSample * _GausValues[0];
                for (int k = 1; k < 5; ++k)
                {
                    result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(_BlurAmount * k, 0.0)) *
                        _GausValues[k];
                    result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(_BlurAmount * k, 0.0)) *
                        _GausValues[k];
                }
                return result;
            }
            ENDHLSL
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment Vertical

            float4 Vertical(VaryingsDefault i) : SV_TARGET
            {
                float4 initSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                if (all(initSample == float4(0, 0, 0, 1)))
                    return initSample;
                float4 result = initSample * _GausValues[0];
                for (int k = 1; k < 5; ++k)
                {
                    result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0.0, _BlurAmount * k)) *
                        _GausValues[k];
                    result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(0.0, _BlurAmount * k)) *
                        _GausValues[k];
                }
                return result;
            }
            ENDHLSL
        }
    }
}