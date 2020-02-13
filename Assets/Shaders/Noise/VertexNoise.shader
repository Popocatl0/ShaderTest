Shader "Noise/VertexNoise"
{
    Properties
    {
		_CellSize("Cell Size", Range(0, 16)) = 2
		[Header(Perlin Noise)]
		[IntRange]_Roughness("Roughness", Range(1, 8)) = 3
		_Persistance("Persistance", Range(0, 1)) = 0.4
		_TimeScale("Time Scale", Range(0, 16)) = 2

		[Header(Waves)]
		_ScrollDirection("Scroll Direction", Vector) = (0, 1, 0, 0)
		_Amplitude("Amplitude", Range(0, 10)) = 1
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
			#pragma multi_compile _PERIOD_NOISE
            #include "UnityCG.cginc"
			#include "LayeredNoise.cginc"
			#define OCTAVES 8

			fixed _CellSize;

			fixed _Roughness;
			fixed _Persistance;
			fixed _TimeScale;

			fixed3 _ScrollDirection;
			fixed _Amplitude;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				half2 value = i.uv * _CellSize;
				//half noise = sampleLayeredNoise(value * 20, OCTAVES, _Persistance, _Roughness, _Amplitude) + 0.5;
				half noise = voronoiNoise(value * 20 ).z;
				return noise;
            }
            ENDCG
        }
    }
}
