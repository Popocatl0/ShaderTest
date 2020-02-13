Shader "Custom/Dissolve"
{
    Properties
    {
		_Color("Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DissolveTex ("Disolve", 2D) = "white" {}
		_DissolveAmount("Dissolve Amount", Range(-1, 1)) = 0.5

		_CellSize("Cell Size", Range(0, 100)) = 1
		_DissolveDirection("Dissolve Direction", vector) = (0, 1, 0, 0)
		_Direction("Direction", vector) = (0, 1, 0, 0)
		[Header(Glow)]
		[HDR]_GlowColor("Color", Color) = (1, 1, 1, 1)
		_GlowRange("Range", Range(0, .5)) = 0.1
		_GlowFalloff("Falloff", Range(0, 1)) = 0.1

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

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon fullforwardshadows  vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
		//#pragma multi_compile  _VERTEX_COLOR
		#include "Noise/LayeredNoise.cginc"
		#define OCTAVES 4

        //sampler2D _MainTex;
		sampler2D _DissolveTex;

		fixed _DissolveAmount;
		fixed _CellSize;
		fixed3 _Direction, _DissolveDirection;
		fixed3 _GlowColor;
		fixed _GlowRange;
		fixed _GlowFalloff;
		
		#include "Toon/SurfaceToon.cginc"

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_DissolveTex;
			float3 vertexColor; // Vertex color stored here by vert() method
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertexColor = mul(unity_ObjectToWorld, v.vertex.xyz);
			half test = ((dot(o.vertexColor, float3(0, -1, 0)) + 1) / 2) - _DissolveAmount * 3;
			float squaresStep = step(test, rand2dTo1d(floor(o.uv_MainTex * _CellSize) * _DissolveAmount * 3));
			v.vertex.xyz += _Direction * squaresStep * rand2dTo1d(v.vertex.xy) * abs(test);
		}

        void surf(Input IN, inout SurfaceOutputToon o)
        {
            // Albedo comes from a texture tinted by color
			half2 value = IN.uv_DissolveTex * _CellSize;
			value += _DissolveDirection * _Time.xyz;
			half dissolve = tex2D(_DissolveTex, value).r * 0.999;
			fixed isVisible = dissolve - _DissolveAmount;
			clip(isVisible);

			fixed isGlowing = smoothstep(_GlowRange + _GlowFalloff, _GlowRange, isVisible);
			fixed3 glow = isGlowing * _GlowColor;

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
            o.Alpha = c.a * _Color.a;
			o.Emission = glow;

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
