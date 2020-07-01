function grating = MakeGrating(chb_x,chb_y, stripe_width)

%  angle is clockwise from right horizont
%  eccentricity is from center to periphery

% chb_x = 1280;
% chb_y = 720;
% stripe_width = 160;

[x y] = meshgrid(-chb_x:(chb_x-1), -chb_y:(chb_y-1));

board1 = zeros(2*chb_y,2*chb_x);

ec = stripe_width;
ec_ex = 0;
trans = 1;
x_min = min(min(x));

for i = 1: ((2*chb_x+1)/stripe_width)
    board1 = board1 + trans*(x>=(x_min +ec_ex) & x < (x_min+ ec));
    ec = ec + stripe_width;
    ec_ex = ec_ex + stripe_width;
    trans = -trans;
end
grating = board1;

end
