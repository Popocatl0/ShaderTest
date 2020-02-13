Shader "Custom/Water"
{
    Properties
    {
		_WaterColor("Water Color", Color) = (1, 1, 1, .5)
		_WaveColor("Water Wave Color", Color) = (1, 1, 1, .5)
		_FoamColor("Foam Color", Color) = (1, 1, 1, .5)

		_MainTex("Main Texture", 2D) = "white" {}
		_NoiseTex("Extra Wave Noise", 2D) = "white" {}

		_TextureDistort("Texture Wobble", range(0,1)) = 0.1
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Scale("Scale", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Foam("Foamline Thickness", Range(0,3)) = 0.5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Transparent"}
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			GrabPass{
				Name "BASE"
				Tags{ "LightMode" = "Always" }
			}
			Pass
			{
				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"

				sampler2D _MainTex, _NoiseTex;
				fixed4 _MainTex_ST;
				fixed4 _WaterColor, _WaveColor, _FoamColor;
				fixed _TextureDistort, _Speed, _Amount, _Height, _Foam, _Scale;

				uniform sampler2D _CameraDepthTexture; //Depth Texture
				uniform float3 _Position;
				uniform sampler2D _GlobalEffectRT;
				uniform float _OrthographicCamSize;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 scrPos : TEXCOORD1;
					float4 worldPos : TEXCOORD2;
					UNITY_FOG_COORDS(1)
				};


				v2f vert (appdata v)
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					float4 tex = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));//extra noise tex
					v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount * tex)) * _Height;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.scrPos = ComputeScreenPos(o.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					UNITY_TRANSFER_FOG(o, o.vertex);
					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					half2 uv = i.worldPos.xz - _Position.xz;
					uv = uv / (_OrthographicCamSize * 2);
					uv += 0.5;

					half ripples = tex2D(_GlobalEffectRT, uv).b;
					ripples = step(0.99, ripples * 3);
					fixed4 ripplesColored = ripples * _FoamColor;

					fixed distortx = tex2D(_NoiseTex, (i.worldPos.xz * _Scale) + (_Time.x * 2)).r;// distortion
					distortx += (ripples * 2);

					fixed4 col = tex2D(_MainTex, (i.worldPos.xz * _Scale) - (distortx * _TextureDistort));
					col = lerp(_WaveColor, _WaterColor, col);

					half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos))); // depth
					half4 foamLine = 1 - saturate(_Foam * (depth - i.scrPos.w));// foam line by comparing depth and screenposition
					//col += foamLine * _FoamColor; // add the foam line and tint to the texture
					col += (step(0.4 * distortx, foamLine) * _FoamColor);

					return saturate(col + ripplesColored);
				}
            ENDCG
        }
    }
}
