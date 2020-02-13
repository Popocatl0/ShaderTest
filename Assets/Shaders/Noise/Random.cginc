#ifndef WHITE_NOISE
	#define WHITE_NOISE

//to 1d functions

		half rand3dTo1d(half3 vec, half3 dotDir = half3(12.9898, 78.233, 37.719)) {
			//make value smaller to avoid artefacts
			float3 smallValue = sin(vec);
			//get scalar value from 3d vector
			half random = dot(smallValue, dotDir);
			//make value more random by making it bigger and then taking teh factional part
			random = frac(sin(random) * 143758.5453);
			return random;
		}

		half rand2dTo1d(half2 value, half2 dotDir = half2(12.9898, 78.233)) {
			half2 smallValue = sin(value);
			half random = dot(smallValue, dotDir);
			random = frac(sin(random) * 143758.5453);
			return random;
		}

		half rand1dTo1d(half value, half mutator = 0.546) {
			half random = frac(sin(value + mutator) * 143758.5453);
			return random;
		}

//to 2d functions

		half2 rand3dTo2d(half3 value) {
			return half2(
				rand3dTo1d(value, half3(12.989, 78.233, 37.719)),
				rand3dTo1d(value, half3(39.346, 11.135, 83.155))
			);
		}

		half2 rand2dTo2d(half2 value) {
			return half2(
				rand2dTo1d(value, half2(12.989, 78.233)),
				rand2dTo1d(value, half2(39.346, 11.135))
			);
		}

		half2 rand1dTo2d(half value) {
			return half2(
				rand1dTo1d(value, 3.9812),
				rand1dTo1d(value, 7.1536)
			);
		}


//to 3d functions

		half3 rand3dTo3d(half3 value) {
			return half3(
				rand3dTo1d(value, half3(12.989, 78.233, 37.719)),
				rand3dTo1d(value, half3(39.346, 11.135, 83.155)),
				rand3dTo1d(value, half3(73.156, 52.235, 09.151))
			);
		}

		half3 rand2dTo3d(float2 value) {
			return half3(
				rand2dTo1d(value, half2(12.989, 78.233)),
				rand2dTo1d(value, half2(39.346, 11.135)),
				rand2dTo1d(value, half2(73.156, 52.235))
			);
		}

		half3 rand1dTo3d(float value) {
			return half3(
				rand1dTo1d(value, 3.9812),
				rand1dTo1d(value, 7.1536),
				rand1dTo1d(value, 5.7241)
			);
		}
#endif

//MODULO-------------------------------------------------
half2 modulo(half2 divident, half2 divisor) {
	half2 positiveDivident = divident % divisor + divisor;
	return positiveDivident % divisor;
}

half3 modulo(half3 divident, half3 divisor) {
	half3 positiveDivident = divident % divisor + divisor;
	return positiveDivident % divisor;
}
//-------------------------------------------------------

//EASE INTERPOLATION-------------------------------------
inline half easeIn(half interpolator) {
	return interpolator * interpolator;
}
half easeOut(half interpolator) {
	return 1 - easeIn(1 - interpolator);
}
half easeInOut(half interpolator) {
	half easeInValue = easeIn(interpolator);
	half easeOutValue = easeOut(interpolator);
	return lerp(easeInValue, easeOutValue, interpolator);
}
//--------------------------------------------------------
