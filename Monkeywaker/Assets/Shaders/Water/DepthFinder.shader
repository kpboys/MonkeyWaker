Shader "Unlit/DepthFinder"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _BlurAmount("Blur Amount", float) = 0.1
        _DepthThreshold("Depth Threshold", float) = 0.5
        _RangeMod("Range Mod", float) = 10
        _StepSize("Step Size", float) = 0.05
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _Color;
            float _BlurAmount;
            float _DepthThreshold;
            float _RangeMod;
            float _StepSize;
            static const float _GausValues[5] = {
                0.227027, 
                0.1945946, 
                0.1216216, 
                0.054054, 
                0.016216
                };

            //Not using these atm, just the regular view of the camera is fine
            sampler2D _CameraDepthNormalsTexture;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_CameraDepthTexture, i.uv).r;
                // float depth;
                // float3 normal;
                // DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
                // fixed4 col = depth;
                // fixed4 col = float4(normal, 1);
                // fixed4 col = step(_DepthThreshold, depth);
                // fixed4 col = tex2D(_CameraDepthTexture, i.uv).r;

                // fixed facto = _BlurAmount;
                // fixed4 col00 = tex2D(_MainTex, i.uv + fixed2(-facto, facto)).w;
                // fixed4 col01 = tex2D(_MainTex, i.uv + fixed2(-facto, 0)).w;
                // fixed4 col02 = tex2D(_MainTex, i.uv + fixed2(-facto, -facto)).w;
                // fixed4 col10 = tex2D(_MainTex, i.uv + fixed2(0, facto)).w;
                // fixed4 col11 = tex2D(_MainTex, i.uv).w; //Center
                // fixed4 col12 = tex2D(_MainTex, i.uv + fixed2(0, -facto)).w;
                // fixed4 col20 = tex2D(_MainTex, i.uv + fixed2(facto, facto)).w;
                // fixed4 col21 = tex2D(_MainTex, i.uv + fixed2(facto, 0)).w;
                // fixed4 col22 = tex2D(_MainTex, i.uv + fixed2(facto, -facto)).w;
                // return (col00 + col01 + col02 + col10 + col11 + col12 + col20 + col21 + col22) / 9;

                // return tex2D(_MainTex, i.uv).w;
                // float2 tex_offset = _MainTex_TexelSize;
                // float2 tex_offset = float2(_BlurAmount, _BlurAmount);
                // float result = tex2D(_MainTex, i.uv).w * _DepthThreshold * _GausValues[0];

                // for(int k = 1; k < 5; k++)
                // {
                //     result += tex2D(_MainTex, i.uv + float2(tex_offset.x * k, 0)).w * _DepthThreshold * _GausValues[k];
                //     result += tex2D(_MainTex, i.uv - float2(tex_offset.x * k, 0)).w * _DepthThreshold * _GausValues[k];
                //     result += tex2D(_MainTex, i.uv + float2(0, tex_offset.y * k)).w * _DepthThreshold * _GausValues[k];
                //     result += tex2D(_MainTex, i.uv - float2(0, tex_offset.y * k)).w * _DepthThreshold * _GausValues[k];
                //     for(int m = 1; m < 5; m++)
                //     {
                //         float gaus = min(_GausValues[m], _GausValues[k]) * (1.0 - (((float)k + (float)m) / 8.0));
                //         result += tex2D(_MainTex, i.uv + float2(tex_offset.x * k, tex_offset.y * m)).w *  _DepthThreshold * gaus;
                //         result += tex2D(_MainTex, i.uv + float2(-tex_offset.x * k, tex_offset.y * m)).w * _DepthThreshold * gaus;
                //         result += tex2D(_MainTex, i.uv - float2(tex_offset.x * k, tex_offset.y * m)).w *  _DepthThreshold * gaus;
                //         result += tex2D(_MainTex, i.uv - float2(-tex_offset.x * k, tex_offset.y * m)).w * _DepthThreshold * gaus;
                //     }
                // }
                float4 result = tex2D(_MainTex, i.uv) * _DepthThreshold * _GausValues[0];
                for(int h = 1; h < _RangeMod; h++)
                {
                    float added = 1 + (_StepSize * h);
                    float2 tex_offset = float2(_BlurAmount * added, _BlurAmount * added);
                    for(int k = 1; k < 5; k++)
                    {
                        result += tex2D(_MainTex, i.uv + float2(tex_offset.x * k, 0)) * _DepthThreshold * _GausValues[k];
                        result += tex2D(_MainTex, i.uv - float2(tex_offset.x * k, 0)) * _DepthThreshold * _GausValues[k];
                        result += tex2D(_MainTex, i.uv + float2(0, tex_offset.y * k)) * _DepthThreshold * _GausValues[k];
                        result += tex2D(_MainTex, i.uv - float2(0, tex_offset.y * k)) * _DepthThreshold * _GausValues[k];
                        for(int m = 1; m < 5; m++)
                        {
                            float gaus = min(_GausValues[m], _GausValues[k]) * (1.0 - (((float)k + (float)m) / 8.0));
                            result += tex2D(_MainTex, i.uv + float2( tex_offset.x * k, tex_offset.y * m)) * _DepthThreshold * gaus;
                            result += tex2D(_MainTex, i.uv + float2(-tex_offset.x * k, tex_offset.y * m)) * _DepthThreshold * gaus;
                            result += tex2D(_MainTex, i.uv - float2( tex_offset.x * k, tex_offset.y * m)) * _DepthThreshold * gaus;
                            result += tex2D(_MainTex, i.uv - float2(-tex_offset.x * k, tex_offset.y * m)) * _DepthThreshold * gaus;
                        }
                    }
                }

                return result.w / _RangeMod;
            }
            ENDCG
        }
    }
}
