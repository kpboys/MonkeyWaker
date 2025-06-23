Shader "Shader Examples/Fire"
{
    Properties
    {
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
        _MaskTexture ("Mask Texture", 2D) = "white" {}
		_ColorTexture("Color Texture", 2D) = "white" {}
		_ScrollSpeed("Scroll Speed", Vector) = (0.1,0.1,0,0)
		_PulseSpeed("Pulse Speed", Float) = 2
		_BillboardScale("Billboard Scale", Float) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }

        Pass
        {
			Blend One One //Additive Blend Mode
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
            };

            sampler2D _NoiseTexture;
            float4 _NoiseTexture_ST;

            sampler2D _MaskTexture;
			sampler2D _ColorTexture;

			float4 _ScrollSpeed;
			float _PulseSpeed;
			float _BillboardScale;

            v2f vert (appdata v)
            {
                v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return 0.2;
            }
            ENDCG
        }
    }
}
