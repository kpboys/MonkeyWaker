Shader "Custom/NormalsEdgeTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorForDepth("Color For Depth", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                float4 vertex : SV_POSITION;
                float2 screenuv : TEXCOORD2;
                float depth : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorForDepth;

            sampler2D _CameraDepthNormalsTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) / 2;
                o.screenuv.y = 1 - o.screenuv.y;
                o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenuv).zw);
                float diff = screenDepth - i.depth;
                float intersect = 0;

                if(diff > 0)
                    intersect = 1 - smoothstep(0,_ProjectionParams.w * 0.5, diff);

                // fixed4 col = fixed4(lerp(_ColorForDepth.rbg, fixed3(1,1,1),pow(intersect,4)),1);
                fixed4 col = _ColorForDepth * _ColorForDepth.a + intersect;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
