Shader "Water/GausTextureEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurDistance("Blur Distance", float) = 1.0
        _GausAmplifier("Gaus Amplifier", float) = 1.0
        _Horizontal("Horizontal", int) = 1
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
                float4 pos : POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _BlurDistance;
            float _GausAmplifier;
            int _Horizontal;
            static const float _GausValues[5] = {
                0.227027, 
                0.1945946, 
                0.1216216, 
                0.054054, 
                0.016216
                };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed result = tex2D(_MainTex, i.uv).w * _GausValues[0] * _GausAmplifier;
                float2 tex_offset = float2(_MainTex_TexelSize.x * _BlurDistance, 
                                            _MainTex_TexelSize.y * _BlurDistance);
                for(int k = 1; k < 5; k++)
                {
                    float2 uvOffset = 
                            float2(tex_offset.x * k * _Horizontal, tex_offset.y * k * (1-_Horizontal));
                            
                    result += tex2D(_MainTex, i.uv + uvOffset).w * _GausValues[k] * _GausAmplifier;
                    result += tex2D(_MainTex, i.uv - uvOffset).w * _GausValues[k] * _GausAmplifier;
                }
                return result;
            }
            ENDCG
        }
    }
}
