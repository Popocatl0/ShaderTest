Shader "Custom/Grass"
{
	Properties
	{
		_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
		_TessellationEdgeLength("Tessellation Edge Length", Range(0.1, 100)) = 5

		_TopColor("Top", Color) = (1,1,1,1)
		_TopColor2("Top2", Color) = (1,1,1,1)
		_BottomColor("Bottom", Color) = (1,1,1,1)
		_BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2
		_BladeForward("Blade Forward Amount", Float) = 0.38
		_BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2

		_BladeWidth("Blade Width", Float) = 0.05
		_BladeWidthRandom("Blade Width Random", Float) = 0.02
		_BladeHeight("Blade Height", Float) = 0.5
		_BladeHeightRandom("Blade Height Random", Float) = 0.3

		_WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
		_WindStrength("Wind Strength", Float) = 1
		_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}

		_CellSize("Cell Size", Range(0, 100)) = 1
		_Persistance("Persistance", Range(0, 1)) = 0.5
		_Roughness("Roughness", Range(1, 8)) = 2
	}

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "Noise/LayeredNoise.cginc"
		#include "Tessellation/CustomTessellation.cginc"
		#define OCTAVES 4

		fixed _BendRotationRandom;
		fixed _BladeForward;
		fixed _BladeCurve;

		fixed _BladeWidth;
		fixed _BladeWidthRandom;
		fixed _BladeHeight;
		fixed _BladeHeightRandom;

		fixed _CellSize;
		fixed _Persistance;
		fixed _Roughness;

		fixed2 _WindFrequency;
		fixed _WindStrength;
		sampler2D _WindDistortionMap;
		float4 _WindDistortionMap_ST;

		#define BLADE_SEGMENTS 3

		geometryOutput VertexOutput(float3 pos, float2 uv, float3 normal)
		{
			geometryOutput o;
			o.pos = UnityObjectToClipPos(pos);
			o.normal = UnityObjectToWorldNormal(normal);;
			o.uv = uv;
			o._ShadowCoord = ComputeScreenPos(o.pos);
#if UNITY_PASS_SHADOWCASTER
			// Applying the bias prevents artifacts from appearing on the surface.
			o.pos = UnityApplyLinearShadowBias(o.pos);
#endif
			return o;
		}

		float3x3 AngleAxis3x3(float angle, float3 axis)
		{
			float c, s;
			sincos(angle, s, c);

			float t = 1 - c;
			float x = axis.x;
			float y = axis.y;
			float z = axis.z;

			return float3x3(
				t * x * x + c, t * x * y - s * z, t * x * z + s * y,
				t * x * y + s * z, t * y * y + c, t * y * z - s * x,
				t * x * z - s * y, t * y * z + s * x, t * z * z + c
				);
		}

		geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix) {
			float3 tangentPoint = float3(width, forward, height);

			float3 tangentNormal = normalize(float3(0, -1, forward));
			float3 localNormal = mul(transformMatrix, tangentNormal);

			float3 localPos = vertexPosition + mul(transformMatrix, tangentPoint);
			return VertexOutput(localPos, uv, localNormal);
		}

		[maxvertexcount((BLADE_SEGMENTS * 2 + 1) * 2)]
		void geo(triangle v2f IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
		{
			float3 pos = IN[0].vertex;
			float3 vNormal = IN[0].normal;
			float4 vTangent = IN[0].tangent;
			float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

			float3x3 tangentToLocal = float3x3(
				vTangent.x, vBinormal.x, vNormal.x,
				vTangent.y, vBinormal.y, vNormal.y,
				vTangent.z, vBinormal.z, vNormal.z
				);

			float3x3 facingRotationMatrix = AngleAxis3x3(rand3dTo1d(pos) * -UNITY_PI, float3(0, 0, 1));

			float3x3 bendRotationMatrix = AngleAxis3x3(rand3dTo1d(pos) * -_BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));

			float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
			float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
			float3 wind = normalize(float3(windSample.x, windSample.y, 0));
			float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);

			half2 value = IN[0].uv * _CellSize;
			half noise = sampleLayeredNoise(value * 20, OCTAVES, _Persistance, _Roughness) + 0.5;

			float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
			float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);

			float height = (rand3dTo1d(pos) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
			float width = (rand3dTo1d(pos) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
			float forward = rand3dTo1d(pos) * _BladeForward;

			for (int i = 0; i < BLADE_SEGMENTS; i++)
			{
				float t = i / (float)BLADE_SEGMENTS;
				float segmentHeight = height * t;
				float segmentWidth = width * (1 - t);
				float segmentForward = pow(t, _BladeCurve) * forward;

				float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;

				triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(noise, t), transformMatrix));
				triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(noise, t), transformMatrix));
			}
			triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(noise, 1), transformationMatrix));

		}
		ENDCG
	SubShader
	{
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
		LOD 100
		Cull off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma hull hull
			#pragma domain domain
			#pragma geometry geo
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
			fixed4 _TopColor;
			fixed4 _TopColor2;
			fixed4 _BottomColor;

			fixed4 frag(geometryOutput i, fixed facing : VFACE) : SV_Target
			{
				float3 normal = facing > 0 ? i.normal : -i.normal;
				half shadow = SHADOW_ATTENUATION(i);
				half NdotL = saturate(saturate(dot(normal, _WorldSpaceLightPos0))) * shadow;
				half3 ambient = ShadeSH9(half4(normal, 1));
				half4 lightIntensity = NdotL * _LightColor0 + half4(ambient, 1);

				fixed4 top = lerp(_TopColor, _TopColor2, i.uv.x);
				half4 col = lerp(_BottomColor, top * lightIntensity, i.uv.y);
				return col;
			}

			ENDCG
        }
		
		/*Pass
		{
			Tags
			{
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geo
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma target 4.6
			#pragma multi_compile_shadowcaster

			float4 frag(geometryOutput i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}*/


    }
}
