Shader "Custom/WaterVer2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _CloudShadowColor("Cloud Shadow Color", Color) = (1,1,1,1)
        [Space]
        _EffectTexScale("Effect Texture Scale", float) = 1
        [Space]
        _ShoreColorTerrain("Shore Color Terrain", Color) = (1,1,1,1)
        _ShoreDistModTerrain("Shore Distance Terrain", float) = 1
        _ShoreMinTerrain("Shore Min Terrain", float) = 0.1
        [Space]
        _ShoreColorObject("Shore Color Object", Color) = (1,1,1,1)
        _ShoreDistModObject("Shore Distance Object", float) = 1
        _ShoreMinObject("Shore Min Object", float) = 0.1
        [Space]
        _WaveColorTerrain("Wave Color Terrain", Color) = (1,1,1,1)
        //X = Distance, Y = Frequency, Z = Speed, W = Thickness
        _WaveStatsTerrain("Wave Stats Terrain", Vector) = (1,1,1,1)
        [Space]
        _WaveColorObject("Wave Color Object", Color) = (1,1,1,1)
        //X = Distance, Y = Frequency, Z = Speed, W = Thickness
        _WaveStatsObject("Wave Stats Object", Vector) = (1,1,1,1)
        [Space]
        _WaterLinesColor("Water Lines Color", Color) = (1,1,1,1)
        _WaterPerlinStep("Water Perlin Step", Range(0,1)) = 0.5
        _WaterPerlinStepTwo("Water Perlin Step Two", Range(0,1)) = 0.5
        _WaterOneScaleMotion("Water One Scale Motion", Vector) = (1,1,1,1)
        _WaterTwoScaleMotion("Water Two Scale Motion", Vector) = (1,1,1,1)

        _WaveTexTerrain("Wave Texture Terrain", 2D) = "white" {}
        _WaveTexObject("Wave Texture Object", 2D) = "white" {}
        _ShoreTexObject("Shore Texture Object", 2D) = "white" {}
        _ShoreTexTerrain("Shore Texture Terrain", 2D) = "white" {}
        // _CloudAlphaTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                float2 wTuv : TEXCOORD3;
                float2 wOuv : TEXCOORD4;
                float2 sTuv : TEXCOORD5;
                float2 sOuv : TEXCOORD6;
                SHADOW_COORDS(7)
            };
            float4 _BaseColor;

            float4 _CloudShadowColor;

            float _EffectTexScale;

            float4 _ShoreColorTerrain;
            float _ShoreDistModTerrain;
            float _ShoreMinTerrain;

            float4 _ShoreColorObject;
            float _ShoreDistModObject;
            float _ShoreMinObject;

            float4 _WaveColorTerrain;
            float4 _WaveStatsTerrain;

            float4 _WaveColorObject;
            float4 _WaveStatsObject;
            
            float4 _WaterLinesColor;
            float _WaterPerlinStep;
            float _WaterPerlinStepTwo;
            float4 _WaterOneScaleMotion;
            float4 _WaterTwoScaleMotion;

            sampler2D _WaveTexTerrain;
            float4 _WaveTexTerrain_ST;
            sampler2D _WaveTexObject;
            float4 _WaveTexObject_ST;
            sampler2D _ShoreTexObject;
            float4 _ShoreTexObject_ST;
            sampler2D _ShoreTexTerrain;
            float4 _ShoreTexTerrain_ST;

            #include "CloudShadows.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.wTuv = TRANSFORM_TEX(v.uv, _WaveTexTerrain);
                o.wOuv = TRANSFORM_TEX(v.uv, _WaveTexObject);
                o.sTuv = TRANSFORM_TEX(v.uv, _ShoreTexTerrain);
                o.sOuv = TRANSFORM_TEX(v.uv, _ShoreTexObject);

                TRANSFER_SHADOW(o);

                float sinValue = ((_Time.x * _WaveStatsTerrain.z) 
                                + _WaveStatsTerrain.w) * _WaveStatsTerrain.y;

                o.pos.y -= (sin(sinValue) * _WaveStatsTerrain.x);

                return o;
            }
            float4 maxing(float4 linesEffect, float4 sTEffect, float4 sOEffect, float4 wTEffect, float4 wOEffect)
            {
                sTEffect *= (1-step(0.001, wTEffect));
                float4 m1 = max(linesEffect, sTEffect);
                float4 m2 = max(m1, sOEffect);
                float4 m3 = max(m2, wTEffect);
                float4 m4 = max(m3, wOEffect);

                return m4;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 scaledUVOne = i.uv * _WaterOneScaleMotion.xy * _EffectTexScale;
                float2 scaledUVTwo = i.uv * _WaterTwoScaleMotion.xy * _EffectTexScale;

                float2 movingUVOne = _WaterOneScaleMotion.zw * _Time.x;
                float2 movingUVTwo = _WaterTwoScaleMotion.zw * _Time.x;

                float4 perlinWaterOne = 1-tex2D(_MainTex,scaledUVOne + movingUVOne).w;
                float4 perlinWaterTwo = 1-tex2D(_MainTex,scaledUVTwo + movingUVTwo).w;
                float4 combino = (perlinWaterOne + perlinWaterTwo)/2;
                
                float4 waterLinesEffect = step(_WaterPerlinStep, combino) 
                                    - step(_WaterPerlinStep + _WaterPerlinStepTwo, combino);
                waterLinesEffect *= _WaterLinesColor; 

                float shoreMapTerrain = (tex2D(_ShoreTexTerrain, i.sTuv * _EffectTexScale).w);
                float4 shoreEffectTerrain = 
                    step(_ShoreMinTerrain, (shoreMapTerrain) * _ShoreDistModTerrain) 
                    * _ShoreColorTerrain;

                float shoreMapObject = (tex2D(_ShoreTexObject, i.sOuv * _EffectTexScale).w);
                float4 shoreEffectObject =  
                    step(_ShoreMinObject, (shoreMapObject) * _ShoreDistModObject) 
                    * _ShoreColorObject;

 
                float waveMapTerrain = (tex2D(_WaveTexTerrain, i.wTuv * _EffectTexScale).w);

                float wTSinValue = ((_Time.x * _WaveStatsTerrain.z) + (1-waveMapTerrain)) * _WaveStatsTerrain.y;
                float wTStep = step(_WaveStatsTerrain.w, sin(wTSinValue));

                float4 waveEffectTerrain = _WaveColorTerrain * 
                                    smoothstep(0, _WaveStatsTerrain.x, waveMapTerrain) * wTStep;


                float waveMapObject = (tex2D(_WaveTexObject, i.wOuv * _EffectTexScale).w);

                float wOSinValue = ((_Time.x * _WaveStatsObject.z) + (1-waveMapObject)) * _WaveStatsObject.y;
                float wOStep = step(_WaveStatsObject.w, sin(wOSinValue));

                float4 waveEffectObject = _WaveColorObject * 
                                    smoothstep(0, _WaveStatsObject.x, waveMapObject) * wOStep;
                
                float4 total = maxing(waterLinesEffect, shoreEffectTerrain, shoreEffectObject, waveEffectTerrain, waveEffectObject);

                return (_BaseColor + total) - (1-_CloudShadowColor) * (1-CLOUD_SHADOW_MASK(i));
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
