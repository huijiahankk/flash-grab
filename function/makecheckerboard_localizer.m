function [checks] = makecheckerboard_localizer(sectorRadius_out_pixel,white,black,grey)

% Number of white/black circle pairs
rcycles = 4; %2

% Number of white/black angular segment pairs (integer)
tcycles = 10;%12

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (sectorRadius_out_pixel*2 - 1): xylim,...
    -xylim: 2 * xylim / (sectorRadius_out_pixel*2  - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* checks + grey * ~circle;