Shader "Unlit/SpikeyGrassShader"
{
    Properties
    {
        _WindStrength("Wind Strength", Range(0,1)) = 1
        _WindSpeed("Wind Speed", float) = 1
        _WindDirection("Wind Direction", Range(0,360)) = 0
        _SwayPosition("Sway Position", float) = 1

        _DiffuseTex ("Diffuse", 2D) = "white" {}
        _AlphaTex ("Alpha", 2D) = "white" {}
        _WindNoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseSpread("Noise Spread", Range(0,30)) = 1
        _CloudColor("Cloud Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull OFF
        ZWrite Off

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
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD6;
            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD6;
                float4 worldPos : TEXCOORD4;
                float4 vertex : SV_POSITION;
                SHADOW_COORDS(7)
            };

            sampler2D _WindNoiseTex;
            float4 _WindNoiseTex_ST;
            float _NoiseSpread;

            float _WindStrength;
            float _WindSpeed;
            float _SwayPosition;
            float _WindDirection;

            float4 _CloudColor;

            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;

            sampler2D _AlphaTex;
            float4 _AlphaTex_ST;

            #include "CloudShadows.cginc"

            v2f vert(appdata v)
            {
                v2f o;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                float4 windUV = float4(
                    o.worldPos.x / _WindNoiseTex_ST.x,
                    o.worldPos.z / _WindNoiseTex_ST.y,
                    0,
                    1
                );
                fixed windMask = 1 - tex2Dlod(_WindNoiseTex, windUV);

                //  World Displacement
                float uvMask = pow(saturate(v.uv1.y - 0.1), 2);
                float displacement = ((sin(_Time.x * 40 * _WindSpeed + windMask * _NoiseSpread) + 1) * _WindStrength +
                    _SwayPosition) * uvMask;
                float4 modifiedWorldPos = float4(
                    o.worldPos.x + displacement * cos(radians(_WindDirection)),
                    o.worldPos.y,
                    o.worldPos.z + displacement * sin(radians(_WindDirection)),
                    o.worldPos.w);

                o.vertex = mul(UNITY_MATRIX_VP, modifiedWorldPos);
                o.uv1 = TRANSFORM_TEX(v.uv1, _DiffuseTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _AlphaTex);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //  Texture Sample
                fixed4 col = fixed4(tex2D(_DiffuseTex, i.uv1).rgb, tex2D(_AlphaTex, i.uv2).a);

                return col - ((1-_CloudColor) * (1-CLOUD_SHADOW_MASK(i)));
            }
            ENDCG
        }
    }
}