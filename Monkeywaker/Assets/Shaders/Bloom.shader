Shader "Hidden/Custom/Bloom"
{
    HLSLINCLUDE
    // StdLib.hlsl holds pre-configured vertex shaders (VertDefault)
    // varying structs (VaryingsDefault), and most of the data you need to write common effects.
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_SourceTex, sampler_SourceTex);
    float _Threshold;
    TEXTURE2D_SAMPLER2D(_FakeDepthTexture, sampler_FakeDepthTexture);
    float4 _UnderlayCol;
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
            #pragma fragment BrightIsolate

            ///Use to check color brightness
            float4 CheckBright(float4 color)
            {
                const float3 lef = float3(0.2126729, 0.7151522, 0.0721750);
                const float brightness = dot(color.rgb, lef); //Finds brightness
                if (brightness > _Threshold) //Checks brigthness against threshold
                    return float4(color.rgb, 1); //Return frag color
                else
                    return float4(0, 0, 0, 1); //Return black
            }

            float4 BrightIsolate(VaryingsDefault i) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                float4 brightCol = CheckBright(col);
                float depth = SAMPLE_TEXTURE2D(_FakeDepthTexture, sampler_FakeDepthTexture, i.texcoord).w;
                //This removes regular blur on objects in the scene
                brightCol *= (1-depth);
                return brightCol;
            }
            ENDHLSL
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment Combine
            

            float4 Combine(VaryingsDefault i) : SV_TARGET
            {
                float4 skySeen = SAMPLE_TEXTURE2D(_FakeDepthTexture, sampler_FakeDepthTexture, i.texcoord);
                //Check if the pixel we are looking at on the fake depth is completely red
                //We then use this to nullify the bloom effect where it would hit the water plane
                float isUnderlay = skySeen != _UnderlayCol;
                float3 blur = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord).rgb;
                float3 src = SAMPLE_TEXTURE2D(_SourceTex, sampler_SourceTex, i.texcoord).rgb;
                //Multiplying by skySeen.w removes the blur on pixels that are in the skybox
                //The isUnderlay makes removes the blur on the ocean
                float3 color = (blur * (skySeen.w) * (isUnderlay)) + src;
                return float4(color.rgb, 1);
            }
            
            ENDHLSL
        }
    }
}