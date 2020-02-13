sampler2D _MainTex;
half _OutlineWidth;
half4 _OutlineColor;

struct appdata {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 texCoord : TEXCOORD0;
};

struct v2f {
	float4 pos : POSITION;
	float4 uv : TEXCOORD0;
};

#if _CAMERA_OUTLINE
//Outline respecto a camara
v2f vert(appdata v) {
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	float3 norm = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, v.normal));
	float2 offset = normalize(norm.xy)  * (_OutlineWidth / 10) * o.pos.w;
	o.pos.xy += offset;
	o.uv = v.texCoord;
	return o;
}
#else
//Outline del modelo
v2f vert(appdata v) {
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);

	float2 offset = TransformViewToProjection(norm.xy) * (_OutlineWidth / 10);
	o.pos.xy += offset;
	o.uv = v.texCoord;
	return o;
}
#endif

#if _COLOR_OULINE
//Outline solo Color
half4 frag(v2f i) : SV_TARGET{
	return _OutlineColor;
}
#else

//Outline con Textura
half4 frag(v2f i) : COLOR{
	fixed4 cLight = tex2D(_MainTex, i.uv.xy) * _OutlineColor;
	return cLight;
}

#endif