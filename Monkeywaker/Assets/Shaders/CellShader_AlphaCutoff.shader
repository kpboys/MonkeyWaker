Shader "Unlit/CellShader_AlphaCutoff"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _CellThreshold("Cell Threshold", Range(-1, 1)) = 0.5
        _CellThresholdWidth("Threshold Width", Range(0, 0.2)) = 0.05
        _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        // _CloudAlphaTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="TransparentCutoutS"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        ZTest Always
		Pass
		{ 
       
			Tags { "LightMode" = "ShadowCaster"}
            
			CGPROGRAM
			#pragma target 3.0

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
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;

			// float4 vert(appdata v) : SV_POSITION
			// {   
			// 	return UnityObjectToClipPos(v.vertex);
			// }

			// half4 frag() : SV_TARGET
			// {
			// 	return 0;
			// }
            v2f vert(appdata v)
			{
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
                float4 surf = tex2D(_MainTex, i.uv);
                //Calling "discard" removes the pixel/fragment entirely, thus affecting shadow casting
                //The function "clip()" does nearly the same, but just < and not <=
                if(surf.w <= 0){
                    discard;
                }
				return 1;
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
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;  
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 worldPos : TEXCOORD1;
                SHADOW_COORDS(5)
            };

            float4 _Color;
            float _CellThreshold;
            float _CellThresholdWidth;
            float _LightThreshold;
            float _ShadowIntensity;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float3 _LightColor0;

            #include "CloudShadows.cginc"
            #include "Phong.cginc"

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 surfaceColor = tex2D(_MainTex, i.uv) * _Color;

				float3 l = normalize(_WorldSpaceLightPos0);
				float3 n = normalize(i.normal); 

                float cellMask = saturate(smoothstep(_CellThreshold - _CellThresholdWidth, _CellThreshold + _CellThresholdWidth, dot(l,n)));

                fixed light = 1 - (1 - (cellMask * SHADOW_ATTENUATION(i))) * _ShadowIntensity;

                float3 cellLight = _LightColor0 * surfaceColor * light;

                return half4(Phong_A(surfaceColor) + cellLight * CLOUD_SHADOW_MASK(i), surfaceColor.w);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
