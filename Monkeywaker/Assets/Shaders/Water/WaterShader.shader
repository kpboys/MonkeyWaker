Shader "Custom/Water"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
        _NoiseTex("Noise", 2D) = "white" {}
        _NoiseMod("Noise Mod", float) = 0.5
        _DistMod("Distance Mod", float) = 1.0
        _WaveMod("Wave Mod", float) = 1.0
        _WaveColor("Wave Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // Blend SrcAlpha OneMinusSrcAlpha

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
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD4;
            };

			float4 _Color;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _NoiseMod;
            float _DistMod;
            float _WaveMod;
            float4 _WaveColor;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }
            sampler2D _CameraDepthTexture; 
            float4 rollingWave(v2f i)
            {
                float sceneDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.screenPos).r);
                //Rolling waves
                // float4 foam = (sceneDepth - i.screenPos.w) * (_DistMod + (sin((_Time + ((i.uv.x + i.uv.y) * 5)) * _WaveMod)));
                float4 foam = (sceneDepth - i.screenPos.w) * _DistMod;
                // float foamMod = (sceneDepth - i.screenPos.w) * _DistMod;
            
                foam = (saturate(foam.x), saturate(foam.y), saturate(foam.z), saturate(foam.w));
                
                // return float4(_Color + (((1-foam) * _WaveColor) + _WaveColor * (saturate(sin((_Time.x + foamMod) * 10)))));
                return float4(_Color + (((1-foam) * _WaveColor)));

				return float4((_Color + 
                            smoothstep(-1, _NoiseMod, tex2D(_NoiseTex, float2(i.uv.x, i.uv.y + _Time.x))) + //Noise
                            ((1-foam.xyz) * _WaveColor)).xyz, //Waves at edges
                            _Color.w); //Water transparency
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return rollingWave(i);
            }
            ENDCG
        }
    }
}
