
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

struct SurfaceOutputToon {
	fixed3 Albedo;
	fixed3 Normal;
	fixed3 Emission;
	half Specular;
	half ShadowThreshold;
	fixed Alpha;
};

#if _VERTEX_COLOR
void vert(inout appdata_full v, out Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);
	o.vertexColor = v.color; // Save the Vertex Color in the Input for the surf() method
}
#endif

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