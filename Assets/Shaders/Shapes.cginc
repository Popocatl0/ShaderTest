//BÁSICAS/////////////////////////////////////////////

//CIRCULO
half circle(half2 value, half radius = 0.5, half smooth = 0, half2 center = 0.5) {
	half d = dot(value - center, value - center)*4.0;
	half pct = 1.0 - smoothstep(radius - (radius*smooth), radius + (radius*smooth), d);
	return pct;
}

//ANILLO
half ring(half2 value, half radius = 0.5, half width = 0.1, half smooth = 0, half center = 0.5) {
	half c = circle(value, radius, smooth);
	half c2 = 1.0 - circle(value, radius + width, smooth);
	return c2 + c;
}

//LINEA
half stripLine(half value, half width = 0.5, half smooth = 0, half2 center = 0.5) {
	half d = distance(value, center);
	half pct = 1.0 - smoothstep(width - (width*smooth), width + (width*smooth), d);
	return pct;
}

//CUADRADO
half box(half2 value, half size = 0.5, half smooth = 0, half2 center = 0.5) {
	half b = stripLine(value.x, size, smooth, center);
	half h = stripLine(value.y, size, smooth, center);
	return b * h;
}

//CUADRADO - SOLO PERIMETRO
half lineBox(half2 value, half size = 0.5, half width = 0.1, half smooth = 0, half2 center = 0.5) {
	half i = box(value, size, smooth, center);
	half o = 1.0 - box(value, size + width, smooth, center);
	return i + o;
}

//RECTANGULO
half rect(half2 value, half2 size = 0.5, half smooth = 0.001, half center = 0.5) {
	half2 pos = center - size * 0.5;
	half2 b = smoothstep(pos, pos + smooth, value);
	b *= smoothstep(pos, pos + smooth, 1.0 - value);
	return b.x * b.y;
}

//CRUZ
half cross(half2 value, half size, half width = 4.0) {
	return  rect(value, half2(size, size / width)) + rect(value, half2(size / width, size));
}

//POLARES////////////////////////////////////////////////////////

//CARTESIANO A POLAR
half2 toPolar(half2 value, half2 center = 0.5) {// x <- r, y <- a
	half2 pos = center - value;
	half2 polar = half2(length(pos)*2.0, atan2(pos.y, pos.x));
	return polar;
}
//POLAR A CARTESIANO
//half2 fromPolar(){}


//CARDIODE
half cardiode(half2 value, half form, half size = 1.0, half smooth = 0.1) {
	half2 polar = toPolar(value);
	float f = cos(polar.y*form);
	return 1. - smoothstep(f, f + smooth, polar.x / size);
}

//FLOR
half flower(half2 value, half leaf, half leafSize = 0.5, half baseSize = 0.3, half size = 1.0, half smooth = 0.01) {
	half2 polar = toPolar(value);
	float f = abs(cos(polar.y*leaf)) * leafSize + baseSize;
	return 1. - smoothstep(f, f + smooth, polar.x / size);
}

//ENGRANE
half engine(half2 value, half leaf, half leafSize = 0.25, half baseSize = 0.5, half smoothLeaf = 1.0, half smoothBase = -0.5, half size = 1.0, half smooth = 0.01) {
	half2 polar = toPolar(value);
	float f = smoothstep(smoothBase, smoothLeaf, cos(polar.y*leaf))*leafSize + baseSize;
	return 1. - smoothstep(f, f + smooth, polar.x / size);
}

//POLIGONOS
half shape(half2 value, half N, half rotate = 1, half edges = 0.5, half size = 0.5, half smooth = 0.01) {
	half2 polar = value * 2 - 1;

	half a = atan2(polar.x, polar.y) + UNITY_PI * rotate;
	half r = UNITY_TWO_PI / N;
	half d = cos(floor(edges + a / r)*r - a)*length(polar);

	return 1.0 - smoothstep(size, size + smooth, d);
}

//DISTANCE FIELD/////////////////////////////////////////////////////////////////////
half distanceField(half2 value, half distance, half minVal, half inStep, half outStep, half inSmooth = 0.01, half outSmooth = 0.01) {
	value = value * 2.0 - 1.0;
	half d = length(min(abs(value) - distance, minVal));
	half c = smoothstep(inStep, inStep + inSmooth, d)* smoothstep(outStep + outSmooth, outStep, d);
	return c;
}

//MATRICES DE TRANSFORMACION////////////////////////////////////////////////////////
half2 rotate2D(half2 value, half angle, half pivot = 0.5) {
	value -= pivot;
	half2x2 mat = half2x2(cos(angle), -sin(angle),
		sin(angle), cos(angle));
	value = mul(mat, value);
	value += pivot;
	return value;
}

half2 scale2D(half2 value, half2 scale, half pivot = 0.5) {
	half2x2 mat = half2x2(scale.x, 0.0,
		0.0, scale.y);
	value -= pivot;
	value = mul(mat, value);
	value += pivot;

	return value;
}

half2 rotateTilePattern(half2 _st) {

	//  Scale the coordinate system by 2x2
	_st *= 2.0;

	//  Give each cell an index number
	//  according to its position
	float index = 0.0;
	index += step(1., (_st.x % 2.0));
	index += step(1., (_st.y % 2.0))*2.0;

	//      |
	//  2   |   3
	//      |
	//--------------
	//      |
	//  0   |   1
	//      |

	// Make each cell between 0.0 - 1.0
	_st = frac(_st);

	// Rotate each cell according to the index
	if (index == 1.0) {
		//  Rotate cell 1 by 90 degrees
		_st = rotate2D(_st, UNITY_PI*-0.5);
	}
	else if (index == 2.0) {
		//  Rotate cell 2 by -90 degrees
		_st = rotate2D(_st, UNITY_PI*0.5);
	}
	else if (index == 3.0) {
		//  Rotate cell 3 by 180 degrees
		_st = rotate2D(_st, UNITY_PI);
	}

	return _st;
}

//YUV COLORS///////////////////////////////////////////////
half3 yuv2rgb(half3 value) {
	half3x3 yuv = half3x3(1.0, 0.0, 1.13983,
		1.0, -0.39465, -0.58060,
		1.0, 2.03211, 0.0);

	half3 color = mul(yuv, value);
	return color;
}

half3 rgb2yuv(half3 value) {
	half3x3 rgb = half3x3(0.2126, 0.7152, 0.0722,
		-0.09991, -0.33609, 0.43600,
		0.615, -0.5586, -0.05639);

	half3 color = mul(rgb, value);
	return color;
}


//HSB COLORS///////////////////////////////////////////////////////
half3 rgb2hsb(in half3 c) {
	half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
	half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
	half d = q.x - min(q.w, q.y);
	half e = 1.0e-10;
	return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
half3 hsb2rgb(in half3 c) {
	half3 rgb = clamp(abs((c.x*6.0 + half3(0.0, 4.0, 2.0) % 6.0) - 3.0) - 1.0, 0.0, 1.0);
	rgb = rgb * rgb*(3.0 - 2.0*rgb);
	return c.z * lerp(1.0, rgb, c.y);
}

//TILES
half2 tiled(half2 value, half space, half offset = 0.0, half offsetVertical = 0.0) {
	half2 t = value * space;
	half vertical = t.x;
	t.x += step(1.0, (t.y % 2.0)) * offset;
	t.y += step(1.0, (vertical % 2.0)) * offsetVertical;
	t = frac(t);
	return t;
}

half2 doubletiled(half2 value, half space, half offset = 0.0, half offsetVertical = 0.0) {
	half2 t = value * space;
	half vert = step(1.0, (t.x % 2.0));
	half hort = step(1.0, (t.y % 2.0));
	t.x += (2.0*step(1.0, hort) - 1.0) * offset;
	t.y += (2.0*step(1.0, vert) - 1.0) * offsetVertical;
	t = frac(t);
	return t;
}
