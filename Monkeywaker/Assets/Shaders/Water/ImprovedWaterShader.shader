Shader "Custom/ImprovedWaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _ShoreColor("Shore Color", Color) = (1,1,1,1)
        _ShoreColDistMod("Shore Color Distance", float) = 1

        _WaveColor("Wave Color", Color) = (1,1,1,1)
        _WaveDistMod("Wave Distance", float) = 1
        _WaveFrequency("Wave Frequency", float) = 1
        _WaveSpeed("Wave Speed", float) = 1
        _WaveThickness("Wave Thickness", Range(0,1)) = 0.8

        _BreakColor("Break Color", Color) = (1,1,1,1)

        _GradientAmplifier("Gradient Amplifier", float) = 1.0
        [Space]
        _WaterLinesColor("Water Lines Color", Color) = (1,1,1,1)
        _WaterPerlinStep("Water Perlin Step", Range(0,1)) = 0.5
        _WaterPerlinStepTwo("Water Perlin Step Two", Range(0,1)) = 0.5
        _WaterOneScaleMotion("Water One Scale Motion", Vector) = (1,1,1,1)
        _WaterTwoScaleMotion("Water Two Scale Motion", Vector) = (1,1,1,1)

        _TerrainTex("Terrain Texture", 2D) = "white" {}
        _ObjectsTex("Objects Texture", 2D) = "white" {}
        _BreakObjectsTex("Break Objects Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD4;
                float4 projPos : TEXCOORD3;
            };
            float4 _Color;
            float4 _ShoreColor;
            float _ShoreColDistMod;

            float4 _WaveColor;
            float _WaveDistMod;
            float _WaveFrequency;
            float _WaveSpeed;
            float _WaveThickness;

            float4 _BreakColor;

            float _GradientAmplifier;

            float4 _WaterLinesColor;
            float _WaterPerlinStep;
            float _WaterPerlinStepTwo;
            float4 _WaterOneScaleMotion;
            float4 _WaterTwoScaleMotion;

            sampler2D _TerrainTex;
            sampler2D _ObjectsTex;
            sampler2D _BreakObjectsTex;

            sampler2D _CameraDepthTexture; 
            sampler2D _CameraDepthNormalsTexture;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.projPos = mul(UNITY_MATRIX_P, v.vertex);
                return o;
            }
            static float DepthBlend (float4 projPos, float threshold, sampler2D cameraDepthTexture)
            {
                float screenPosNorm = projPos.z / projPos.w;
                screenPosNorm = (UNITY_NEAR_CLIP_VALUE >= 0) ? screenPosNorm : screenPosNorm * 0.5 + 0.5;

                float depthBlend = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(cameraDepthTexture, UNITY_PROJ_COORD(projPos))));

                depthBlend = abs((depthBlend - LinearEyeDepth(screenPosNorm)) / (threshold));

                return saturate(depthBlend);
            } 

            fixed4 frag (v2f i) : SV_Target
            {
                float2 scaledUVOne = i.uv * _WaterOneScaleMotion.xy;
                float2 scaledUVTwo = i.uv * _WaterTwoScaleMotion.xy;

                float2 movingUVOne = _WaterOneScaleMotion.zw * _Time.x;
                float2 movingUVTwo = _WaterTwoScaleMotion.zw * _Time.x;

                float4 perlinWaterOne = 1-tex2D(_MainTex,scaledUVOne + movingUVOne).w;
                float4 perlinWaterTwo = 1-tex2D(_MainTex,scaledUVTwo + movingUVTwo).w;
                float4 combino = (perlinWaterOne + perlinWaterTwo)/2;

                float4 stepped = step(_WaterPerlinStep, combino) - step(_WaterPerlinStep + _WaterPerlinStepTwo, combino);
                stepped *= _WaterLinesColor; 

                float depthMap = (1 - tex2D(_TerrainTex, i.uv).w) * (1 - tex2D(_ObjectsTex, i.uv).w);
                depthMap += step(depthMap, 0.9999999) * _GradientAmplifier;

                float4 shoreEffect =  smoothstep(0.2, 0.21,  (1-depthMap) * _ShoreColDistMod) * _ShoreColor;
                float4 waveEffect = smoothstep(0, 3, (1- depthMap) * _WaveDistMod) * _WaveColor * step(_WaveThickness, saturate(sin(((_Time.x * _WaveSpeed) + depthMap) * _WaveFrequency)));
                // float4 waveEffect = _Color;

                // return 1-depthMap * _WaveColor;

                float breakMap = tex2D(_BreakObjectsTex, i.uv).w;
                // float4 breakEffect = pow(breakMap,2.2) * 5 * _BreakColor;
                float4 breakEffect = smoothstep(0.2, 0.4, breakMap) * _BreakColor;

                // float4 total = (max(stepped, shoreEffect) + max(shoreEffect, waveEffect) + max(waveEffect, stepped)) / 3;
                // return _Color + total;

                return float4(_Color + stepped + shoreEffect + waveEffect + breakEffect);
            }
            ENDCG
        }
    }
}
