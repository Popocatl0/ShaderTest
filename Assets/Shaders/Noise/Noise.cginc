#include "Random.cginc"

//VALUE NOISE---------------------------------------------

//Interpolacion en un eje para testeo
half interpolateInY(half noise, half posy) {
	half dist = abs(noise - posy);
	half pixelHeight = fwidth(posy);
	half lineIntensity = smoothstep(2 * pixelHeight, pixelHeight, dist);
	return lerp(1, 0, lineIntensity);
}

//Noise en un eje
half valueNoise(half value) {
	half previousCellNoise = rand1dTo1d(floor(value));
	half nextCellNoise = rand1dTo1d(ceil(value));
	half interpolator = frac(value);
	interpolator = easeInOut(interpolator);
	return lerp(previousCellNoise, nextCellNoise, interpolator);
}
//Noise 2D
half valueNoise(half2 value) {
	half upperLeftCell = rand2dTo1d(half2(floor(value.x), ceil(value.y)));
	half upperRightCell = rand2dTo1d(half2(ceil(value.x), ceil(value.y)));
	half lowerLeftCell = rand2dTo1d(half2(floor(value.x), floor(value.y)));
	half lowerRightCell = rand2dTo1d(half2(ceil(value.x), floor(value.y)));

	half interpolatorX = easeInOut(frac(value.x));
	half interpolatorY = easeInOut(frac(value.y));

	half upperCells = lerp(upperLeftCell, upperRightCell, interpolatorX);
	half lowerCells = lerp(lowerLeftCell, lowerRightCell, interpolatorX);

	half noise = lerp(lowerCells, upperCells, interpolatorY);
	return noise;
}
        
//Noise 3D
half valueNoise(half3 value) {
	half interpolatorX = easeInOut(frac(value.x));
	half interpolatorY = easeInOut(frac(value.y));
	half interpolatorZ = easeInOut(frac(value.z));

	half cellNoiseZ[2];
	[unroll]
	for (int z = 0; z <= 1; z++) {
		half cellNoiseY[2];
		[unroll]
		for (int y = 0; y <= 1; y++) {
			half cellNoiseX[2];
			[unroll]
			for (int x = 0; x <= 1; x++) {
				half3 cell = floor(value) + half3(x, y, z);
				cellNoiseX[x] = rand3dTo1d(cell);
			}
			cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
		}
		cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
	}
	half noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
	return noise;
}
//Noise 3D - return Color
half3 valueNoise3d(half3 value) {
	half interpolatorX = easeInOut(frac(value.x));
	half interpolatorY = easeInOut(frac(value.y));
	half interpolatorZ = easeInOut(frac(value.z));

	half3 cellNoiseZ[2];
	[unroll]
	for (int z = 0; z <= 1; z++) {
		half3 cellNoiseY[2];
		[unroll]
		for (int y = 0; y <= 1; y++) {
			half3 cellNoiseX[2];
			[unroll]
			for (int x = 0; x <= 1; x++) {
				half3 cell = floor(value) + half3(x, y, z);
				cellNoiseX[x] = rand3dTo3d(cell);
			}
			cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
		}
		cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
	}
	half3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
	return noise;
}
//----------------------------------------------------------------------------------

//PERLIN NOISE---------------------------------------------------------------------

/*
Para marcar las lineas noise = abs(noise);
*/

//Gradient
half gradientNoise(half value) {
	half fraction = frac(value);
	half interpolator = easeInOut(fraction);

	half previousCellInclination = rand1dTo1d(floor(value)) * 2 - 1;
	half previousCellLinePoint = previousCellInclination * fraction;

	half nextCellInclination = rand1dTo1d(ceil(value)) * 2 - 1;
	half nextCellLinePoint = nextCellInclination * (fraction - 1);

	return lerp(previousCellLinePoint, nextCellLinePoint, interpolator);
}

//Perlin 2d Period
half perlinNoise(half2 value, half2 period = 1) {
	half2 fraction = frac(value);

	half2 cellsMimimum = floor(value);
	half2 cellsMaximum = ceil(value);

#if _PERIOD_NOISE
	cellsMimimum = modulo(cellsMimimum, period);
	cellsMaximum = modulo(cellsMaximum, period);
#endif

	half2 lowerLeftDirection = rand2dTo2d(half2(cellsMimimum.x, cellsMimimum.y)) * 2 - 1;
	half2 lowerRightDirection = rand2dTo2d(half2(cellsMaximum.x, cellsMimimum.y)) * 2 - 1;
	half2 upperLeftDirection = rand2dTo2d(half2(cellsMimimum.x, cellsMaximum.y)) * 2 - 1;
	half2 upperRightDirection = rand2dTo2d(half2(cellsMaximum.x, cellsMaximum.y)) * 2 - 1;

	half lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - half2(0, 0));
	half lowerRightFunctionValue = dot(lowerRightDirection, fraction - half2(1, 0));
	half upperLeftFunctionValue = dot(upperLeftDirection, fraction - half2(0, 1));
	half upperRightFunctionValue = dot(upperRightDirection, fraction - half2(1, 1));


	half interpolatorX = easeInOut(fraction.x);
	half interpolatorY = easeInOut(fraction.y);

	half lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
	half upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);

	half noise = lerp(lowerCells, upperCells, interpolatorY);
	return noise;
}

//Perlin 3d Period
half perlinNoise(half3 value, half3 period=1) {
	half3 fraction = frac(value);

	half interpolatorX = easeInOut(fraction.x);
	half interpolatorY = easeInOut(fraction.y);
	half interpolatorZ = easeInOut(fraction.z);

	half3 cellNoiseZ[2];
	[unroll]
	for (int z = 0; z <= 1; z++) {
		half3 cellNoiseY[2];
		[unroll]
		for (int y = 0; y <= 1; y++) {
			half3 cellNoiseX[2];
			[unroll]
			for (int x = 0; x <= 1; x++) {
				half3 cell = floor(value) + half3(x, y, z);
#if _PERIOD_NOISE
				cell = modulo(cell, period);
#endif
				half3 cellDirection = rand3dTo3d(cell) * 2 - 1;
				half3 compareVector = fraction - half3(x, y, z);
				cellNoiseX[x] = dot(cellDirection, compareVector);
			}
			cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
		}
		cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
	}
	half3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
	return noise;
}

//Marcar lineas
half linePerlin(half noise, half value = 6) {
	noise = frac(noise * value);
	half pixelNoiseChange = fwidth(noise);
	half heightLine = smoothstep(1 - pixelNoiseChange, 1, noise);
	heightLine += smoothstep(pixelNoiseChange, 0, noise);
	return heightLine;
}
//-------------------------------------------------------------------------------------------
//VORONOI------------------------------------------------------------------------------------

//Vorinoi 2d
half3 voronoiNoise(half2 value) {
	half2 baseCell = floor(value);
	half minDistToCell = 10;
	half minEdgeDistance = 10;
	half2 closestCell;
	half2 toClosestCell;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			half2 cellPos = cell + rand2dTo2d(cell);
			half2 toCell = cellPos - value;
			half distToCell = length(toCell);

			if (distToCell < minDistToCell) {
				minDistToCell = distToCell;
				closestCell = cell;
				toClosestCell = toCell;
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
			half2 cellPos = cell + rand2dTo2d(cell);
			half2 toCell = cellPos - value;

			half2 diffToClosestCell = abs(closestCell - cell);
			bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y < 0.1;
			if (!isClosestCell) {
				half2 toCenter = (toClosestCell + toCell) * 0.5;
				half2 cellDifference = normalize(toCell - toClosestCell);
				half edgeDistance = dot(toCenter, cellDifference);
				minEdgeDistance = min(minEdgeDistance, edgeDistance);
			}
		}
	}

	half random = rand2dTo1d(closestCell);
	return half3(minDistToCell, random, minEdgeDistance);
}

//Voronoi 2d Period
half3 voronoiNoise(half2 value, half2 period) {
	half2 baseCell = floor(value);
	half minDistToCell = 10;
	half minEdgeDistance = 10;
	half2 closestCell;
	half2 toClosestCell;
	[unroll]
	for (int x = -1; x <= 1; x++)
	{
		[unroll]
		for (int y = -1; y <= 1; y++)
		{
			half2 cell = baseCell + half2(x, y);
			half2 tiledCell = modulo(cell, period);
			half2 cellPos = cell + rand2dTo2d(tiledCell);
			half2 toCell = cellPos - value;
			half distToCell = length(toCell);

			if (distToCell < minDistToCell) {
				minDistToCell = distToCell;
				closestCell = cell;
				toClosestCell = toCell;
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
			half2 tiledCell = modulo(cell, period);
			half2 cellPos = cell + rand2dTo2d(tiledCell);
			half2 toCell = cellPos - value;

			half2 diffToClosestCell = abs(closestCell - cell);
			bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y < 0.1;
			if (!isClosestCell) {
				half2 toCenter = (toClosestCell + toCell) * 0.5;
				half2 cellDifference = normalize(toCell - toClosestCell);
				half edgeDistance = dot(toCenter, cellDifference);
				minEdgeDistance = min(minEdgeDistance, edgeDistance);
			}
		}
	}

	half random = rand2dTo1d(closestCell);
	return half3(minDistToCell, random, minEdgeDistance);
}

//Voronoi 3d
half3 voronoiNoise(half3 value) {
	half3 baseCell = floor(value);
	half minDistToCell = 10;
	half minEdgeDistance = 10;
	half3 closestCell;
	half3 toClosestCell;
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
				half3 cellPos = cell + rand3dTo3d(cell);
				half3 toCell = cellPos - value;
				half distToCell = length(toCell);

				if (distToCell < minDistToCell) {
					minDistToCell = distToCell;
					closestCell = cell;
					toClosestCell = toCell;
				}
			}
		}
	}

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
				half3 cellPos = cell + rand3dTo3d(cell);
				half3 toCell = cellPos - value;

				half3 diffToClosestCell = abs(closestCell - cell);
				bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
				if (!isClosestCell) {
					half3 toCenter = (toClosestCell + toCell) * 0.5;
					half3 cellDifference = normalize(toCell - toClosestCell);
					half edgeDistance = dot(toCenter, cellDifference);
					minEdgeDistance = min(minEdgeDistance, edgeDistance);
				}
			}
		}
	}

	half random = rand3dTo1d(closestCell);
	return half3(minDistToCell, random, minEdgeDistance);
}

//Voronoi 3d Period
half3 voronoiNoise(half3 value, half3 period) {
	half3 baseCell = floor(value);
	half minDistToCell = 10;
	half minEdgeDistance = 10;
	half3 closestCell;
	half3 toClosestCell;
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
				half3 cellPos = cell + rand3dTo3d(tiledCell);
				half3 toCell = cellPos - value;
				half distToCell = length(toCell);

				if (distToCell < minDistToCell) {
					minDistToCell = distToCell;
					closestCell = cell;
					toClosestCell = toCell;
				}
			}
		}
	}

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
				half3 cellPos = cell + rand3dTo3d(tiledCell);
				half3 toCell = cellPos - value;

				half3 diffToClosestCell = abs(closestCell - cell);
				bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
				if (!isClosestCell) {
					half3 toCenter = (toClosestCell + toCell) * 0.5;
					half3 cellDifference = normalize(toCell - toClosestCell);
					half edgeDistance = dot(toCenter, cellDifference);
					minEdgeDistance = min(minEdgeDistance, edgeDistance);
				}
			}
		}
	}

	half random = rand3dTo1d(closestCell);
	return half3(minDistToCell, random, minEdgeDistance);
}

//Detector de orillas 2d
half3 edgeDetect(half noise, half3 value, half3 borderColor = 0, half3 cellColor = 1) {
	half valueChange = length(fwidth(value)) * 0.5;
	half isBorder = 1 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise);
	half3 color = lerp(cellColor, borderColor, isBorder);
	return color;
}
//Detector de orillas 3d
half3 edgeDetect(half noise, half2 value, half3 borderColor= 1, half3 cellColor = 0) {
	half valueChange = length(fwidth(value)) * 0.5;
	half isBorder = 1 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise);
	half3 color = lerp(cellColor, borderColor, isBorder);
	return color;
}
//---------------------------------------------------------------------------------------------

