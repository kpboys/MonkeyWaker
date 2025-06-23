Shader "Unlit/SurfaceShader"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _SpecColor("Specular Material Color", Color) = (1,1,1,1) 
        _Shininess("Shininess",  Range(1,100)) = 10 
        _SpecularStrength("Specular Strength", Range(0,1)) = 1 
        _DiffuseShadowIntensity("Diffuse Shadow Intensity", Range(0, 1)) = 0.5 
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5

        _DiffuseTex ("Diffuse", 2D) = "white" {}
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
                float2 uv0 : TEXCOORD0;
                float4 worldPos : TEXCOORD4;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;

                #ifdef uv3 //! Spørg Emil om det her nonsense
                    float2 uv3 : TEXCOORD10;
                #endif

                SHADOW_COORDS(5)
                float3 normal : NORMAL;
            };

			float4 _Color;
            float _ShadowIntensity;
            
            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;

            uniform float3 _LightColor0;

            #include "CloudShadows.cginc"
            #include "Phong.cginc"

            v2f vert (appdata v)
            {
                v2f o;

                o.uv0 = TRANSFORM_TEX(v.uv, _DiffuseTex);
                o.uv1 = TRANSFORM_TEX(v.uv, _CloudAlphaTex);
                o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 surfaceCol = _Color;
                fixed4 surfaceCol = tex2D(_DiffuseTex, i.uv0) * _Color;
                
                //  Phong Vectors
                float3 l, n, v, r;
                PhongVectors(i, l, n, v, r);

                //  Light shadows
                fixed shadowMask = 1 - (1 - SHADOW_ATTENUATION(i)) * _ShadowIntensity;

                return fixed4(Phong_A(surfaceCol) + Phong_DS(surfaceCol, l, n, v, r) * shadowMask * CLOUD_SHADOW_MASK(i), 1);
            }
            ENDCG
        }
    }
}
