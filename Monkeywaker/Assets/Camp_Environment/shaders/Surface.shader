﻿Shader "Shader Examples/Surface"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
	
    }
    SubShader
    {
        Pass
        {
			 Tags {	"RenderType" = "Opaque"	}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

			float4 _Color;		

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return 0.7;
            }
            ENDCG
        }

		
    }
}
