Shader "Shader Examples/Flag"
{
    Properties
    {
		_Amplitude("Amplitude", Range(0,4)) = 0.5
		_Frequency("Frequency", Range(0,10)) = 0.5
		_Speed("Speed", Float) = 1
		
		_Tilt("Line Tilt", Range(0,1)) = 0
		_Thickness("Line Thickness", Range(0,0.5)) = 0.2
		_TopColor("Top Color", Color) = (1,0,0,1)
		_MiddleColor("Middle Color", Color) = (0,1,0,1)
		_BottomColor("Bottom Color", Color) = (0,0,1,1)
    }
    SubShader
    {

		Tags { "RenderType" = "Opaque" }
        Pass
        {
			Cull Off //Visible from both sides

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

			fixed _Amplitude;
			fixed _Frequency;
			fixed _Speed;

			fixed _Tilt;
			fixed _Thickness;
			fixed4 _TopColor;
			fixed4 _MiddleColor;
			fixed4 _BottomColor;

            v2f vert (appdata v)
            {
                v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
			
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return 0.5;
            }
            ENDCG
        }
    }
}
