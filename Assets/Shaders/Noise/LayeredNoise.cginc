#include "Noise.cginc"

//SAMPLE LAYERED------------------------------------------------------------------------

//Perlin Sample Layered 2d
half sampleLayeredNoise(half2 value, int OCTAVES, half persistance=0.5, half roughness = 0.1 , half2 period = 1) {
	half noise = 0;
	half frequency = 1;
	half amplitude = 1;

	[unroll]
	for (int i = 0; i < OCTAVES; i++) {
		noise = noise + perlinNoise(value * frequency + i * 0.72354, period * frequency) * amplitude;
		amplitude *= persistance;
		frequency *= roughness;
	}

	return noise;
}

//Perlin Sample Layered 3D
half sampleLayeredNoise(half3 value, int OCTAVES, half persistance=0.5, half roughness=0.1, half3 period = 1) {
	half noise = 0;
	half frequency = 1;
	half amplitude = 1;

	[unroll]
	for (int i = 0; i < OCTAVES; i++) {
		noise = noise + perlinNoise(value * frequency + i * 0.72354, period * frequency) * amplitude;
		amplitude *= persistance;
		frequency *= roughness;
	}
	return noise;
}
//--------------------------------------------------------------------------------------


//Animaciones

//Ondas desde el centro
half stippling(half2 value, half cellSize, half noise, half time = 1) {
	half2 pos = value - (cellSize * 0.5);
	half a = dot(pos, pos) - _Time.y * 0.1 * time;
	half n = step(abs(sin(a*3.1415 * 5.0)), noise * 2.0);
	return n;
}

//Metal Ball 2d
half metalBall(half2 value) {
	half2 baseCell = floor(value);
	half2 fracCell = frac(value);
	half minDistToCell = 1;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			half2 offset = rand2dTo2d(cell);
			offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

			half2 cellPos = half2(x, y) + offset - fracCell;
			half dist = length(cellPos);

			minDistToCell = min(minDistToCell, minDistToCell * dist);
		}
	}
	//n = step(0.060, noise);
	return minDistToCell;
}

//Metal Ball 2d Period
half metalBall(half2 value, half period) {
	half2 baseCell = floor(value);
	half2 fracCell = frac(value);
	half minDistToCell = 1;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			half2 tiledCell = modulo(cell, period);
			half2 offset = rand2dTo2d(tiledCell);
			offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

			half2 cellPos = half2(x, y) + offset - fracCell;
			half dist = length(cellPos);

			minDistToCell = min(minDistToCell, minDistToCell * dist);
		}
	}
	//n = step(0.060, noise);
	return minDistToCell;
}


//Metal Ball 3d
half metalBall(half3 value) {
	half3 baseCell = floor(value);
	half3 fracCell = frac(value);
	half minDistToCell = 1;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			[unroll]
			for (int z = -1; z <= 1; z++)
			{
				half3 cell = baseCell + half3(x, y, z);
				//half2 tiledCell = modulo(cell, 4);
				half3 offset = rand3dTo3d(cell);
				offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

				half3 cellPos = half3(x, y, z) + offset - fracCell;
				half dist = length(cellPos);

				minDistToCell = min(minDistToCell, minDistToCell * dist);
			}
		}
	}
	//n = step(0.060, noise);
	return minDistToCell;
}

//Metal Ball 3d Period
half metalBall(half3 value, half period) {
	half3 baseCell = floor(value);
	half3 fracCell = frac(value);
	half minDistToCell = 1;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			[unroll]
			for (int z = -1; z <= 1; z++)
			{
				half3 cell = baseCell + half3(x, y, z);
				half3 tiledCell = modulo(cell, period);
				half3 offset = rand3dTo3d(tiledCell);
				offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

				half3 cellPos = half3(x, y, z) + offset - fracCell;
				half dist = length(cellPos);

				minDistToCell = min(minDistToCell, minDistToCell * dist);
			}
		}
	}
	//n = step(0.060, noise);
	return minDistToCell;
}

//Metal Ball 2d con deteccion de orillas
half3 metalBallEdge(half2 value) {
	half2 baseCell = floor(value);
	half2 fracCell = frac(value);
	half minDistToCell = 1;
	half minEdgeDistance = 1;
	half2 closestCell;
	half2 toClosestCell;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			//half2 tiledCell = modulo(cell, 4);
			half2 offset = rand2dTo2d(cell);
			offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

			half2 cellPos = half2(x, y) + offset - fracCell;
			half distToCell = length(cellPos);

			if (distToCell < minDistToCell) {
				minDistToCell = distToCell;
				closestCell = cell;
				toClosestCell = cellPos;
			}
		}
	}

	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			//half2 tiledCell = modulo(cell, 4);
			half2 offset = rand2dTo2d(cell);
			offset = 0.5 + 0.5*sin(_Time.y + 6.2831*offset);

			half2 cellPos = half2(x, y) + offset - fracCell;

			half2 diffToClosestCell = abs(closestCell - cell);
			bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y < 0.1;
			if (!isClosestCell) {
				half2 toCenter = (toClosestCell + cellPos) * 0.5;
				half2 cellDifference = normalize(cellPos - toClosestCell);
				half edgeDistance = dot(toCenter, cellDifference);
				minEdgeDistance = min(minEdgeDistance, edgeDistance);
			}
		}
	}

	half random = rand2dTo1d(closestCell);
	return half3(minDistToCell, random, minEdgeDistance);
}


half turbulence(half2 value, int OCTAVES, half lacunarity, half  gain, half2 period = 1) {
	half noise = 0;
	half amplitude = 1;

	[unroll]
	for (int i = 0; i < OCTAVES; i++) {
		noise += abs(perlinNoise(value, period)) * amplitude;
		value *= lacunarity;
		amplitude *= gain;
	}
	return noise;
}

// Ridged multifractal
// See "Texturing & Modeling, A Procedural Approach", Chapter 12
half ridge(half h, half offset) {
	h = abs(h);     // create creases
	h = offset - h; // invert so creases are at top
	h = h * h;      // sharpen creases
	return h;
}

half rigedMF(half2 value, int OCTAVES, half lacunarity, half  gain, half offset = 0.9, half2 period = 1) {
	half noise = 0;

	half sum = 0.0;
	half frequency = 1.0, amplitude = 0.5;
	half prev = 1.0;

	[unroll]
	for (int i = 0; i < OCTAVES; i++) {
		noise = ridge( perlinNoise(value * frequency + i, period * frequency), offset );
		sum += noise*amplitude;
		sum += noise*amplitude*prev;
		prev = noise;
		frequency *= lacunarity;
		amplitude *= gain;
	}

	return sum;
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
half morganNoise(in half2 _st) {
	half2 i = floor(_st);
	half2 f = frac(_st);

	// Four corners in 2D of a tile
	half a = rand2dTo1d(i);
	half b = rand2dTo1d(i + half2(1.0, 0.0));
	half c = rand2dTo1d(i + half2(0.0, 1.0));
	half d = rand2dTo1d(i + half2(1.0, 1.0));

	half2 u = f * f * (3.0 - 2.0 * f);

	return lerp(a, b, u.x) +
		(c - a)* u.y * (1.0 - u.x) +
		(d - b) * u.x * u.y;
}

half fbm(in half2 _st, int OCTAVES) {
	half v = 0.0;
	half a = 0.5;
	half2 shift = half2(100.0, 100.0);
	// Rotate to reduce axial bias
	half2x2 rot = half2x2(cos(0.5), sin(0.5),
		-sin(0.5), cos(0.50));
	for (int i = 0; i < OCTAVES; ++i) {
		v += a * morganNoise(_st);
		_st = mul(rot, _st) * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}




