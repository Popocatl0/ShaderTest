Shader "Toon/Toon"
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
				"RenderType" = "Opaque"
				"Queue" = "Geometry"
			}
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Toon fullforwardshadows vertex:vert

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _SpecularTex;
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

			struct Input
			{
				float2 uv_MainTex;
				float3 vertexColor; // Vertex color stored here by vert() method
			};

			struct SurfaceOutputToon {
				fixed3 Albedo;
				fixed3 Normal;
				fixed3 Emission;
				half Specular;
				half ShadowThreshold;
				fixed Alpha;
			};

			void vert(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input, o);
				o.vertexColor = v.color; // Save the Vertex Color in the Input for the surf() method
			}

			half4 LightingToon(SurfaceOutputToon s, half3 lightDir, half3 viewDir, half shadowAttenuation) {
				half NdotL = dot(s.Normal, lightDir);
				NdotL -= s.ShadowThreshold;
				half NdotLChange = fwidth(NdotL);
				half lightIntensity = smoothstep(0, NdotLChange, NdotL);
				//SHADOWS
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
				float3 reflectionDirection = reflect(lightDir, s.Normal);
				float towardsReflection = dot(viewDir, -reflectionDirection);
				//make specular highlight all off towards outside of model
				float specularFalloff = dot(viewDir, s.Normal);
				specularFalloff = pow(specularFalloff, _SpecularFalloff);
				towardsReflection = towardsReflection * specularFalloff;
				//make specular intensity with a hard corner
				float specularChange = fwidth(towardsReflection);
				float specularIntensity = smoothstep(1 - _SpecularSize, 1 - _SpecularSize + specularChange, towardsReflection);
				//factor inshadows
				half4 specular = specularIntensity * _SpecularColor * s.Specular;

				//RIM
				half4 rimDot = 1 - dot(viewDir, s.Normal);
				half rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				half4 rim = rimIntensity * _RimColor;

				//AMBIENT and SHADOW COLOR
				half4 ambient = lerp(_ShadowTint, _AmbientColor, lightIntensity);
				half4 color;
				color.rgb = s.Albedo * (lightIntensity + ambient + specular + rim) * _LightColor0;
				color.a = s.Alpha;

				return color;
			}

			void surf(Input IN, inout SurfaceOutputToon o)
			{
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
				fixed3 spec = tex2D(_SpecularTex, IN.uv_MainTex).rgb;
				o.Specular = spec.r;

				float vertColor = IN.vertexColor.r;
				o.ShadowThreshold = spec.g;
				o.ShadowThreshold *= vertColor;
				o.ShadowThreshold = lerp(1 - o.ShadowThreshold, o.ShadowThreshold, _ShadowThreshold);
			}
			ENDCG
		}
		FallBack "Diffuse"
}
