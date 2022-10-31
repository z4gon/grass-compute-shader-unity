// Hash lookup table as defined by Ken Perlin.
// This is a randomly arranged array of all numbers from 0-255 inclusive.
// Duplicated to avoid out of bounds.
static const int P[512] = {
    171,137,93,148,32,180,219,77,185,28,9,92,102,18,101,42,0,52,127,
    202,149,4,78,150,237,234,159,23,205,65,189,177,41,112,100,79,122,
    141,64,190,29,25,63,62,94,227,132,108,116,242,13,107,66,250,172,54,
    186,107,125,233,81,18,61,60,241,55,105,239,97,118,248,75,215,54,12,
    88,55,211,162,108,38,106,252,9,157,1,26,246,86,85,24,89,210,211,198,
    67,242,253,1,162,207,92,130,97,137,131,42,164,43,84,73,194,161,236,
    99,194,221,143,10,101,120,163,251,201,168,146,118,173,249,91,104,195,
    8,151,188,35,214,39,202,125,215,181,237,66,221,74,183,153,88,165,226,
    213,254,140,213,78,156,171,22,123,225,50,75,148,23,57,147,246,33,214,51,
    201,145,7,175,61,72,50,98,21,168,99,94,46,156,46,52,58,223,222,29,241,41,
    115,60,147,62,36,2,196,187,224,123,126,83,135,155,208,63,247,7,240,174,
    89,16,191,199,53,16,109,95,208,96,206,203,71,165,207,225,243,232,248,0,
    153,34,5,48,90,244,131,154,103,195,53,218,45,86,73,223,11,119,17,127,230,
    133,203,51,114,173,231,72,30,176,59,142,182,87,204,37,19,49,229,243,90,167,
    235,25,129,8,15,234,71,113,138,193,3,74,190,230,69,4,138,26,135,111,117,59,
    37,238,83,154,136,145,141,28,70,24,49,158,38,206,228,98,175,142,85,31,121,15,
    170,186,128,217,192,200,229,252,103,152,6,217,228,193,179,112,212,69,96,11,
    170,109,140,209,27,22,157,126,12,68,93,231,169,238,251,5,198,110,57,14,250,
    113,122,152,76,255,134,119,124,33,110,106,47,44,205,70,95,249,253,82,56,160,
    178,218,39,134,197,199,132,43,13,254,77,189,220,146,179,136,224,17,236,204,
    144,81,182,188,130,65,129,144,40,219,116,79,176,121,102,128,114,172,30,44,151,
    232,178,27,58,226,45,212,185,191,31,222,120,244,216,166,68,2,160,196,36,139,
    197,239,34,174,149,10,192,87,56,91,35,67,245,40,184,177,167,6,161,143,105,247,
    255,80,180,245,169,100,64,133,150,21,48,155,84,47,240,181,163,227,220,20,209,
    104,235,164,158,19,32,20,115,14,166,183,124,82,200,3,80,184,233,216,117,210,76,187,139,159,111
};

// S shaped curve for fading values given t between 0 and 1
float fade(float t)
{
    // return (6 * pow(t, 5)) - (15 * pow(t, 4)) + (10 * pow(t, 3));
    // return 6*t*t*t*t*t - 15*t*t*t*t + 10*t*t*t;
    return ((6*t - 15)*t + 10)*t*t*t;

}

// pseudo random gradients
float2 gradient(int seed, float time)
{
    return float2(sin(seed + time), cos(seed + time));
}

// perlin noise 0 to 1
// https://adrianb.io/2014/08/09/perlinnoise.html
float perlin(
    float2 uv,
    uint columns,
    uint rows,
    float time = 1
)
{
    // square dimensions
    float squareWidth = 1 / float(columns);
    float squareHeight = 1 / float(rows);

    // current square
    uint column = floor(uv.x / squareWidth);
    uint row = floor(uv.y / squareHeight);

    // corners
    float2 topLeft = float2(0.0,1.0);
    float2 topRight = float2(1.0,1.0);
    float2 bottomLeft = float2(0.0,0.0);
    float2 bottomRight = float2(1.0,0.0);

    // get index for the lookup table
    uint X = column % 256;
    uint Y = row % 256;

    // gradients
    float2 gradientTopLeft = gradient(P[P[X] + Y+1], time);
    float2 gradientTopRight = gradient(P[P[X+1] + Y+1], time);
    float2 gradientBottomLeft = gradient(P[P[X] + Y], time);
    float2 gradientBottomRight = gradient(P[P[X+1] + Y], time);

    // translate point to local square coordinates
    float2 localPoint = float2(
        (uv.x % squareWidth) / squareWidth,
        (uv.y % squareHeight) / squareHeight
    );

    // distances
    float2 distanceTopLeft = localPoint - topLeft;
    float2 distanceTopRight = localPoint - topRight;
    float2 distanceBottomLeft = localPoint - bottomLeft;
    float2 distanceBottomRight = localPoint - bottomRight;

    // dot
    float dotTopLeft = dot(distanceTopLeft, gradientTopLeft);
    float dotTopRight = dot(distanceTopRight, gradientTopRight);
    float dotBottomLeft = dot(distanceBottomLeft, gradientBottomLeft);
    float dotBottomRight = dot(distanceBottomRight, gradientBottomRight);

    // interpolate
    float2 w = float2(fade(localPoint.x), fade(localPoint.y));

    float interpolatedDot = lerp(
        lerp(dotBottomLeft, dotBottomRight, w.x),
        lerp(dotTopLeft, dotTopRight, w.x),
        w.y
    );

    return interpolatedDot;
}
