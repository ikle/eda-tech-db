#!/usr/bin/awk -f 

function abs   (x) { if (x >= 0) return x; else return -x }
function round (x) { return int (x + 0.5) }

BEGIN {
	FS = ","; dx = .66; dy = .56; getline; CSV = 1;

	if (CSV) printf "cell,variant,height,width\n";
}

{
	y = round($3 / dy);
	x = round($4 / dx);

	if (!CSV) {
		printf "%-8s %-3s %5.2f %5.2f ", $1, $2, $3, $4;
		printf "%2d %2d %5.2f %5.2f\n", y, x, abs(y * dy - $3), abs(x * dx - $4);
	}
	else
		printf "%s,%s,%d,%d\n", $1, $2, y, x;
}
