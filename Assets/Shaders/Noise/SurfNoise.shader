Shader "Noise/SurfNoise"
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
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
		#include "LayeredNoise.cginc" 

		#define OCTAVES 4

		fixed _CellSize;
		fixed _Roughness;
		fixed _Persistance;
		fixed _TimeScale;

		fixed3 _ScrollDirection;
		fixed _Amplitude;

        struct Input
        {
			float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			half2 value = IN.worldPos.xz / _CellSize;
			half noise = voronoiNoise(value).x;
			half stip = stippling(value, _CellSize, noise);
			o.Albedo = stip;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
