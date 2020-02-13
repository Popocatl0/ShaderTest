Shader "Custom/Pattern"
{
	Properties
	{
		_CellSize("Cell Size", Range(0, 16)) = 2

		[IntRange]_Step("Roughness", Range(1, 8)) = 3
		_Value1("Value", Range(0, 1)) = 0.4
		_Value2("Value 2", Range(0, 1)) = 0.2
		_Value3("Value 3", Range(0, 1)) = 0.2
		_Value4("Value 4", Range(0, 1)) = 0.2
		_Value5("Value 5", Range(0, 1)) = 0.2
		_Amplitude("Amplitude", Range(0, 10)) = 1

		
		_Vector("Direction", Vector) = (0, 1, 0, 0)
		_Color("Color", Color) = (1.0,1.0,1.0,1)
		_Color2("Color 2", Color) = (1.0,1.0,1.0,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "Noise/LayeredNoise.cginc"
				#include "Shapes.cginc"
				#define OCTAVES 4

				fixed _CellSize;

				fixed _Value1;
				fixed _Value2;
				fixed _Value3;
				fixed _Value4;
				fixed _Value5;
				fixed _Step;
				fixed _Amplitude;

				fixed3 _Vector;
				fixed3 _Color;
				fixed3 _Color2;

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
				

				half plot(half2 st, half pct) {
					return  smoothstep(pct - 0.01, pct, st.y) - smoothstep(pct, pct + 0.01, st.y);
				}


				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}


				fixed3 frag(v2f i) : SV_Target
				{
					half2 value = i.uv * _CellSize;
					value = rotateTilePattern(value);
					value = rotate2D(value, UNITY_PI*_Value2);
					half f = cross(value, _Value1);
					return f;
					/*half2 q = half2(0, 0);
					q.x = fbm(value + 0.1 * _Time.y, OCTAVES);
					q.y = fbm(value + 1.0, OCTAVES);
					 
					half2 r = half2(0, 0);
					r.x = fbm(value + 1 * q + half2(1.7, 9.2) + 0.15*_Time.y, OCTAVES);
					r.x = fbm(value + 1 * q + half2(8.3, 2.8) + 0.126*_Time.y, OCTAVES);

					half f = fbm(value+r, OCTAVES);

					fixed3 color;
					color = lerp(half3(0.101961, 0.619608, 0.666667),
						half3(0.666667, 0.666667, 0.498039),
						clamp((f*f)*4.0, 0.0, 1.0));

					color = lerp(color,
						half3(0, 0, 0.164706),
						clamp(length(q), 0.0, 1.0));

					color = lerp(color,
						half3(0.666667, 1, 1),
						clamp(length(r.x), 0.0, 1.0));

					return (f*f*f + .6*f*f + .5*f)*color;*/
				}
				ENDCG
			}
		}
}
