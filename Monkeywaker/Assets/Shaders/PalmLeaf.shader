Shader "Unlit/PalmLeaf"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _CellThreshold("Cell Threshold", Range(-1, 1)) = 0.5
        _CellThresholdWidth("Threshold Width", Range(0, 0.2)) = 0.05
        _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5

        [Space(20)]
        _WindStrength("Wind Strength", Range(0,1)) = 1
        _WindSpeed("Wind Speed", float) = 1
        _WindDirection("Wind Direction", Range(0,360)) = 0
        _SwayPosition("Sway Position", float) = 1

        [Space]
        _WindExponent("Wind Exponent", float) = 1
        _WindExponentConstant("Wind Exponent Constant", float) = 1
        
        [Space]
        _WindNoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseSpread("Noise Spread", Range(0,30)) = 1

        [Space(20)]
        _MainTex ("Main Texture", 2D) = "white" {}

        _CloudAlphaTex ("Cloud Texture", 2D) = "white" {}
        
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull OFF
        ZWrite Off

        Pass
		{ 
			Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
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

            sampler2D _WindNoiseTex;
            float4 _WindNoiseTex_ST;
            float _NoiseSpread;

            float _WindExponent;
            float _WindExponentConstant;

            float _WindStrength;
            float _WindSpeed;
            float _SwayPosition;
            float _WindDirection;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float3 _LightColor0;
			
            v2f vert(appdata v)
			{
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
        
                float4 windUV = float4
                (
                    worldPos.x / _WindNoiseTex_ST.x,
                    worldPos.z / _WindNoiseTex_ST.y,
                    0,
                    1
                );
                fixed windMask = 1 - tex2Dlod(_WindNoiseTex, windUV);

                float uvMask = pow(saturate(v.uv.x - 0.1), 2);

                float modifiedSpread = _NoiseSpread / 2;
                float hDisplacement = ((pow(_WindExponent, sin(_Time.x * 40 * _WindSpeed + windMask * modifiedSpread)) * _WindExponentConstant + 1) * _WindStrength + _SwayPosition) * uvMask;
                float vDisplacement = (pow(_WindExponent, sin(_Time.x * 26 * _WindSpeed + windMask * modifiedSpread)) * _WindExponentConstant + 1) * _WindStrength * uvMask;

                float4 modifiedWorldPos = float4(
                    worldPos.x + hDisplacement * cos(radians(_WindDirection)),
                    worldPos.y + vDisplacement,
                    worldPos.z + hDisplacement * sin(radians(_WindDirection)),
                    worldPos.w);

                o.pos = mul(UNITY_MATRIX_VP, modifiedWorldPos);
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
            #include  "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                SHADOW_COORDS(5)
            };

            sampler2D _WindNoiseTex;
            float4 _WindNoiseTex_ST;
            float _NoiseSpread;

            float _WindExponent;
            float _WindExponentConstant;

            float4 _Color;
            float _CellThreshold;
            float _CellThresholdWidth;
            float _LightThreshold;
            float _ShadowIntensity;

            float _WindStrength;
            float _WindSpeed;
            float _SwayPosition;
            float _WindDirection;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float3 _LightColor0;

            #include "CloudShadows.cginc"
            #include "Phong.cginc"

            v2f vert(appdata v)
            {
                v2f o;


                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
        
                float4 windUV = float4
                (
                    worldPos.x / _WindNoiseTex_ST.x,
                    worldPos.z / _WindNoiseTex_ST.y,
                    0,
                    1
                );
                fixed windMask = 1 - tex2Dlod(_WindNoiseTex, windUV);

                float uvMask = pow(saturate(v.uv.x - 0.1), 2);

                float modifiedSpread = _NoiseSpread / 2;
                float hDisplacement = ((pow(_WindExponent, sin(_Time.x * 40 * _WindSpeed + windMask * modifiedSpread)) * _WindExponentConstant + 1) * _WindStrength + _SwayPosition) * uvMask;
                float vDisplacement = (pow(_WindExponent, sin(_Time.x * 26 * _WindSpeed + windMask * modifiedSpread)) * _WindExponentConstant + 1) * _WindStrength * uvMask;

                float4 modifiedWorldPos = float4(
                    worldPos.x + hDisplacement * cos(radians(_WindDirection)),
                    worldPos.y + vDisplacement,
                    worldPos.z + hDisplacement * sin(radians(_WindDirection)),
                    worldPos.w);


                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = mul(UNITY_MATRIX_VP, modifiedWorldPos);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //  Texture Sample
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                float3 l = normalize(_WorldSpaceLightPos0);
				float3 n = normalize(i.normal);

                float cellMask = saturate(smoothstep(_CellThreshold - _CellThresholdWidth, _CellThreshold + _CellThresholdWidth, dot(l,n)));

                fixed light = 1 - (1 - (cellMask * SHADOW_ATTENUATION(i))) * _ShadowIntensity;

                float3 cellLight = _LightColor0 * col * light;
                
                return half4(Phong_A(col) + cellLight * CLOUD_SHADOW_MASK(i), col.w);
            }
            ENDCG
        }
    }
}