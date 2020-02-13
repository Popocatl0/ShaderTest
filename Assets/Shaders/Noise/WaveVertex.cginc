#include "LayeredNoise.cginc"
#define OCTAVES 4 

fixed _Persistance;
fixed _Roughness;

fixed _CellSize;
fixed _Amplitude;
fixed2 _ScrollDirection;

#if _VERTEX_TANGET_WAVE
//vertex with shadows
void vert(inout appdata_full data) {
	float3 localPos = data.vertex / data.vertex.w;

	//calculate new posiiton
	float3 modifiedPos = localPos;
	float2 basePosValue = mul(unity_ObjectToWorld, modifiedPos).xz / _CellSize + _ScrollDirection * _Time.y;
	float basePosNoise = sampleLayeredNoise(basePosValue) + 0.5;
	modifiedPos.y += basePosNoise * _Amplitude;

	//calculate new position based on pos + tangent
	float3 posPlusTangent = localPos + data.tangent * 0.02;
	float2 tangentPosValue = mul(unity_ObjectToWorld, posPlusTangent).xz / _CellSize + _ScrollDirection * _Time.y;
	float tangentPosNoise = sampleLayeredNoise(tangentPosValue) + 0.5;
	posPlusTangent.y += tangentPosNoise * _Amplitude;

	//calculate new position based on pos + bitangent
	float3 bitangent = cross(data.normal, data.tangent);
	float3 posPlusBitangent = localPos + bitangent * 0.02;
	float2 bitangentPosValue = mul(unity_ObjectToWorld, posPlusBitangent).xz / _CellSize + _ScrollDirection * _Time.y;
	float bitangentPosNoise = sampleLayeredNoise(bitangentPosValue) + 0.5;
	posPlusBitangent.y += bitangentPosNoise * _Amplitude;

	//get recalculated tangent and bitangent
	float3 modifiedTangent = posPlusTangent - modifiedPos;
	float3 modifiedBitangent = posPlusBitangent - modifiedPos;

	//calculate new normal and set position + normal
	float3 modifiedNormal = cross(modifiedTangent, modifiedBitangent);
	data.normal = normalize(modifiedNormal);
	data.vertex = float4(modifiedPos.xyz, 1);
}

#elif _VERTEX_UNLIT_WAVE
//vertex unlit
void vert(inout appdata_full data) {
	float4 worldPos = mul(unity_ObjectToWorld, data.vertex);
	float3 value = worldPos / _CellSize + _ScrollDirection * _Time.y;
	float3 noise = sampleLayeredNoise(value) + 0.5;
	data.vertex.y += noise.y * _Amplitude;
}
#endif
