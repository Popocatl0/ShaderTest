Shader "Toon/ToonOutlineVertex"
{
    Properties
    {
		[Header(Base Parameters)]
		_Color("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_SpecularSize("Specular Size", Range(0, 1)) = 0.1
		_SpecularFalloff("Specular Falloff", Range(0, 2)) = 1
		_SpecularTex("Specular (R) ShadowThresh (G) Anisotropic Mask (B)", 2D) = "white" {}

		[Header(Rim Parameters)]
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1

		[Header(Lighting Parameters)]
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_ShadowTint("Shadow Color", Color) = (0, 0, 0, 1)
		_ShadowPower("Shadow Power", Range(0,1)) = 0.5
		_ShadowThreshold("Shadow Threshold", Range(-2,2)) = 0.5

		[Header(Outline Parameters)]
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline Width", Range(0, 1)) = 0.03
    }
    SubShader
    {
        Tags { 
			"Queue" = "Transparent+1"
			"IgnoreProjector" = "True"
			"RenderType" = "Overlay"
			"LightMode" = "ForwardBase"
		}
		Blend SrcAlpha OneMinusSrcAlpha, One One
        LOD 200
	
		Pass
		{
			Cull Back
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// Compile multiple versions of this shader depending on lighting settings.
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			// Files below include macros and functions to assist
			// with lighting and shadows.
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SpecularTex;
			float4 _SpecularTex_ST;

			fixed4 _Color;
			half _SpecularSize;
			half _SpecularFalloff;
			half4 _SpecularColor;
			half4 _AmbientColor;

			half4 _RimColor;
			fixed _RimAmount;
			fixed _RimThreshold;

			half4 _ShadowTint;
			fixed _ShadowPower;
			fixed _ShadowThreshold;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				TRANSFER_SHADOW(o)
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half3 normal = normalize(i.worldNormal);
				half3 viewDir = normalize(i.viewDir);
				float4 sample = tex2D(_MainTex, i.uv);

				fixed3 spec = tex2D(_SpecularTex, i.uv).rgb;
				half Specular = spec.r;

				half ShadowThreshold = spec.g;
				//ShadowThreshold *= vertColor;
				ShadowThreshold = lerp(1 - ShadowThreshold, ShadowThreshold, _ShadowThreshold);

				half NdotL = dot(normal, _WorldSpaceLightPos0);
				NdotL -= ShadowThreshold;
				half NdotLChange = fwidth(NdotL);
				half lightIntensity = smoothstep(0, NdotLChange, NdotL);
				
				//SHADOW
				half shadowAttenuation = SHADOW_ATTENUATION(i);
#ifdef USING_DIRECTIONAL_LIGHT
				half attenuationChange = fwidth(shadowAttenuation) * 0.5;
				half shadow = smoothstep(0.5 - attenuationChange, 0.5 + attenuationChange, shadowAttenuation);
#else
				half attenuationChange = fwidth(shadowAttenuation) * 0.5;
				half shadow = smoothstep(0, attenuationChange, shadowAttenuation);
#endif
				lightIntensity = lightIntensity * shadow;

				lightIntensity = lerp(-_ShadowPower, 1, lightIntensity);

				//SPECULAR
				half3 reflectionDirection = reflect(_WorldSpaceLightPos0, normal);
				half towardsReflection = dot(viewDir, -reflectionDirection);
				//make specular highlight all off towards outside of model
				half specularFalloff = dot(viewDir, normal);
				specularFalloff = pow(specularFalloff, _SpecularFalloff);
				towardsReflection = towardsReflection * specularFalloff;
				//make specular intensity with a hard corner
				half specularChange = fwidth(towardsReflection);
				half specularIntensity = smoothstep(1 - _SpecularSize, 1 - _SpecularSize + specularChange, towardsReflection);
				//factor inshadows
				half4 specular = specularIntensity * _SpecularColor * Specular;

				//RIM//
				half4 rimDot = 1 - dot(viewDir, normal);
				half rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				half4 rim = rimIntensity * _RimColor;

				//AMBIENT and SHADOW COLOR//
				half4 ambient = lerp(_ShadowTint, _AmbientColor, lightIntensity);
				half4 color;
				color.rgb = sample.rgb * (lightIntensity + ambient + specular + rim) * _LightColor0 * _Color;
				color.a = sample.a * _Color.a;

				return color;
			}
			ENDCG
		}

		Pass{

			Cull Front
			ZWrite OFF
			ZTest ON
			Stencil
			{
				Ref 4
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Outline.cginc"
			ENDCG
		}
    }
    FallBack "Diffuse"
}
