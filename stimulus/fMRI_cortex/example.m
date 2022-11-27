
out_diameter = 2000;
inner_diameter = 1000;
black = 0;
white = 255;
ramp_slope = 0.1;% bigger slope means change shaper
ramp_degree = 20; % degrees

matrix = DrawRingWithBlurredBoundary(out_diameter,...
    inner_diameter,black,white,ramp_slope,ramp_degree);
imshow(matrix)

