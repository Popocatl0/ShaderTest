
//Fractal Mandlebrot 2d
half2 mandlebrot(half2 value, fixed scale, half2 center, int iteration) {
	half2 c = half2(1.3333 * (value.x - 0.5) * scale - center.x, (value.y - 0.5) * scale - center.y);
	half2 z = c;

	for (int i = 0; i < iteration; i++)
	{
		half x = (z.x * z.x - z.y * z.y) + c.x;
		half y = (z.y * z.x + z.x * z.y) + c.y;

		if ((x*x + y * y) > 4.0)
			break;
		z.x = x;
		z.y = y;
	}

	return (i == iteration ? 0.0 : i) * .01;
}


//Fractal Julia - beta
half2 julia(half2 value, half2 center, int iteration) {
	half2 z = half2(3.0 * value.x - 0.5, 2.0 * value.y - 0.5);

	for (int i = 0; i < iteration; i++)
	{
		half x = (z.x * z.x - z.y * z.y) + center.x;
		half y = (z.y * z.x + z.x * z.y) + center.y;

		if ((x*x + y * y) > 4.0)
			break;
		z.x = x;
		z.y = y;
	}

	return (i == iteration ? 0.0 : i) * .01;
}

//Tablero Ajedrez
//Sin blur half color = step(0, chess);
half chessTable(half2 value, half noise = 0) {
	half2 chess = sin(2 * 3.1416 * 4 * value);
	return (chess.x * chess.y) + noise;
}
