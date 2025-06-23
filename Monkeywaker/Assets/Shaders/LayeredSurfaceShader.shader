Shader "Unlit/LayeredSurfaceShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _SpecColor("Specular Material Color", Color) = (1,1,1,1) 
        _Shininess("Shininess",  Range(1,100)) = 10 
        _SpecularStrength("Specular Strength", Range(0,1)) = 1 
        _DiffuseShadowIntensity("Diffuse Shadow Intensity", Range(0, 2)) = 0.5 
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5
        [Space]

        _Material0Threshold("Material 0 Threshold", float) = 1
        _Material0ThresholdWidth("Material 0 Threshold Width", Range(0, 10)) = 0.1

        _Material1Threshold("Material 1 Threshold", float) = 2
        _Material1ThresholdWidth("Material 1 Threshold Width", Range(0, 10)) = 0.1
        [Space]

        _MaterialSlopesAngle("Material Slopes Angle", Range(0, 90)) = 45
        _MaterialSlopeThresholdWidth("Material Slopes Threshold Width", Range(0, 1)) = 0.1
        [Space(30)]

        _Color0("Color 0", Color) = (1,1,1,1)
        _DiffuseTex0 ("Diffuse 0", 2D) = "white" {}
        _NoiseTex0 ("Noise 0", 2D) = "white" {}
        _Noise0Strength("Noise Strength", Range(0,1)) = 1 
        [Space(30)]

        _Color1("Color 1", Color) = (1,1,1,1)
        _DiffuseTex1 ("Diffuse 1", 2D) = "white" {}
        _NoiseTex1 ("Noise 1", 2D) = "white" {}
        _Noise1Strength("Noise Strength", Range(0,1)) = 1 
        [Space(30)]

        _Color2("Color 2", Color) = (1,1,1,1)
        _DiffuseTex2 ("Diffuse 2", 2D) = "white" {}
        _NoiseTex2 ("Noise 2", 2D) = "white" {}
        _Noise2Strength("Noise Strength", Range(0,1)) = 1 
        [Space(30)]

        _ColorSlope("Color Slopes", Color) = (1,1,1,1)
        _DiffuseTexSlopes ("Diffuse Slopes", 2D) = "white" {}
        _NoiseTexSlopes ("Noise Slopes", 2D) = "white" {}
        _NoiseSlopesStrength("Noise Strength", Range(0,1)) = 1 
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
		{ 
			Tags { "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
			};

			float4 vert(appdata v) : SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}

			half4 frag() : SV_TARGET
			{
				return 0;
			}
			ENDCG
		}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;  
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD4;
                float2 uv0 : TEXCOORD10;
                float2 uv1 : TEXCOORD11;
                float2 uv2 : TEXCOORD12;
                float2 uv3 : TEXCOORD13;
                float2 uv4 : TEXCOORD14;
                float2 uv5 : TEXCOORD15;
                float2 uv6 : TEXCOORD16;
                SHADOW_COORDS(5)
                float3 normal : NORMAL;
            };

            float _Material0Threshold;
            float _Material0ThresholdWidth;

            float _Material1Threshold;
            float _Material1ThresholdWidth;

            float _MaterialSlopesAngle;
            float _MaterialSlopeThresholdWidth;

			float4 _Color;
            float _ShadowIntensity;
            
			float4 _Color0;
            sampler2D _DiffuseTex0;
            float4 _DiffuseTex0_ST;
            sampler2D _NoiseTex0;
            float4 _NoiseTex0_ST;
            float _Noise0Strength;
            
			float4 _Color1;
            sampler2D _DiffuseTex1;
            float4 _DiffuseTex1_ST;
            sampler2D _NoiseTex1;
            float4 _NoiseTex1_ST;
            float _Noise1Strength;

			float4 _Color2;
            sampler2D _DiffuseTex2;
            float4 _DiffuseTex2_ST;
            sampler2D _NoiseTex2;
            float4 _NoiseTex2_ST;
            float _Noise2Strength;
            
			float4 _ColorSlope;
            sampler2D _DiffuseTexSlopes;
            float4 _DiffuseTexSlopes_ST;
            float _NoiseSlopesStrength;

            uniform float3 _LightColor0;

            #include "CloudShadows.cginc"
            #include "Phong.cginc"

            v2f vert (appdata v)
            {
                v2f o;

                o.uv0 = TRANSFORM_TEX(v.uv, _DiffuseTex0);
                o.uv1 = TRANSFORM_TEX(v.uv, _NoiseTex0);
                o.uv2 = TRANSFORM_TEX(v.uv, _DiffuseTex1);
                o.uv3 = TRANSFORM_TEX(v.uv, _NoiseTex1);
                o.uv4 = TRANSFORM_TEX(v.uv, _DiffuseTex2);
                o.uv5 = TRANSFORM_TEX(v.uv, _NoiseTex2);

                o.uv6 = TRANSFORM_TEX(v.uv, _DiffuseTexSlopes);

                o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mat0Mask = 1 - smoothstep(_Material0Threshold - _Material0ThresholdWidth, _Material0Threshold + _Material0ThresholdWidth, i.worldPos.y);
                float mat1Mask = 1 - smoothstep(_Material1Threshold - _Material1ThresholdWidth, _Material1Threshold + _Material1ThresholdWidth, i.worldPos.y) - mat0Mask;
                float mat2Mask = 1 - mat0Mask - mat1Mask;

                float noiseMask0 = 1 - (1 - tex2D(_NoiseTex0, i.uv1)) * _Noise0Strength;
                fixed4 surface0Col = tex2D(_DiffuseTex0, i.uv0) * noiseMask0 * _Color0 * _Color;

                float noiseMask1 = 1 - (1 - tex2D(_NoiseTex1, i.uv3)) * _Noise1Strength;
                fixed4 surface1Col = tex2D(_DiffuseTex1, i.uv2) * noiseMask1 * _Color1 * _Color;

                float noiseMask2 = 1 - (1 - tex2D(_NoiseTex2, i.uv5)) * _Noise2Strength;
                fixed4 surface2Col = tex2D(_DiffuseTex2, i.uv4) * noiseMask2 * _Color2 * _Color;

                fixed4 surfaceCol = (surface0Col * mat0Mask + surface1Col * mat1Mask + surface2Col * mat2Mask) * _Color;
                
                //  Phong Vectors
                float3 l, n, v, r;
                PhongVectors(i, l, n, v, r);

                // Light shadows
                fixed shadowMask = 1 - (1 - SHADOW_ATTENUATION(i)) * _ShadowIntensity;

                return fixed4(Phong_A(surfaceCol) + Phong_DS(surfaceCol, l, n, v, r) * shadowMask * CLOUD_SHADOW_MASK(i), 1);
            }
            ENDCG
        }
    }
}
