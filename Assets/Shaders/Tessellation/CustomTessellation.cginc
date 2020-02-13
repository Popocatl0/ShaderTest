// Tessellation programs based on this article by Catlike Coding:
// https://catlikecoding.com/unity/tutorials/advanced-rendering/tessellation/
#include "Autolight.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
};

struct TessellationControlPoint {
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
};

struct geometryOutput {
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	unityShadowCoord4 _ShadowCoord : TEXCOORD1;
};

struct TessellationFactors
{
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

//inside domain shader
v2f tessVert(TessellationControlPoint v)
{
	v2f o;
	// Note that the vertex is NOT transformed to clip
	// space here; this is done in the geometry shader.
	o.vertex = v.vertex;
	o.normal = v.normal;
	o.tangent = v.tangent;
	o.uv = v.uv;
	return o;
}

//inside geometry shader
geometryOutput VertexOutput(v2f i)
{
	geometryOutput o;
	o.pos = UnityObjectToClipPos(i.vertex);
	o.uv = i.uv;
	o.normal = i.normal; //UnityObjectToWorldNormal(i.normal);
	o._ShadowCoord = ComputeScreenPos(o.pos);
	return o;
}

//Vertex Shader
TessellationControlPoint  vert(appdata v)
{
	TessellationControlPoint p;
	p.vertex = v.vertex;
	p.normal = v.normal;
	p.tangent = v.tangent;
	p.uv = v.uv;
	p.uv1 = v.uv1;
	p.uv2 = v.uv2;
	return p;
}


float _TessellationUniform;
float _TessellationEdgeLength;

float TessellationEdgeFactor(float3 p0, float3 p1) {
/*#if defined(_TESSELLATION_EDGE)
	float3 p0 = mul(unity_ObjectToWorld, float4(cp0.vertex.xyz, 1)).xyz;
	float3 p1 = mul(unity_ObjectToWorld, float4(cp1.vertex.xyz, 1)).xyz;
	float edgeLength = distance(p0, p1);
	return edgeLength / _TessellationEdgeLength;
#else
	return _TessellationUniform;
#endif*/
	/*float4 p0 = UnityObjectToClipPos(cp0.vertex);
	float4 p1 = UnityObjectToClipPos(cp1.vertex);
	float edgeLength = distance(p0.xy / p0.w, p1.xy / p1.w);
	return edgeLength / _TessellationEdgeLength;*/

	float edgeLength = distance(p0, p1);

	float3 edgeCenter = (p0 + p1) * 0.5;
	float viewDistance = distance(edgeCenter, _WorldSpaceCameraPos);

	return edgeLength * _ScreenParams.y / (_TessellationEdgeLength * viewDistance);
}

TessellationFactors patchConstantFunction(InputPatch<TessellationControlPoint, 3> patch)
{
	float3 p0 = mul(unity_ObjectToWorld, patch[0].vertex).xyz;
	float3 p1 = mul(unity_ObjectToWorld, patch[1].vertex).xyz;
	float3 p2 = mul(unity_ObjectToWorld, patch[2].vertex).xyz;

	TessellationFactors f;
	f.edge[0] = TessellationEdgeFactor(p1, p2);
	f.edge[1] = TessellationEdgeFactor(p2, p0);
	f.edge[2] = TessellationEdgeFactor(p0, p1);
	f.inside = (TessellationEdgeFactor(p1, p2) + TessellationEdgeFactor(p2, p0) + TessellationEdgeFactor(p0, p1)) * (1 / 3.0);
	return f;
}

[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_partitioning("integer")]
[UNITY_patchconstantfunc("patchConstantFunction")]
TessellationControlPoint hull(InputPatch<TessellationControlPoint, 3> patch, uint id : SV_OutputControlPointID)
{
	return patch[id];
}

[UNITY_domain("tri")]
v2f domain(TessellationFactors factors, OutputPatch<TessellationControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
	appdata v;

#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = \
		patch[0].fieldName * barycentricCoordinates.x + \
		patch[1].fieldName * barycentricCoordinates.y + \
		patch[2].fieldName * barycentricCoordinates.z;

		MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
		MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
		MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv)
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv1)
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv2)

		return tessVert(v);
}