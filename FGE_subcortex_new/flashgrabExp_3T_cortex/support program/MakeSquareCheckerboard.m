function checkerboard = MakeSquareCheckerboard(chb_x,chb_y, stripe_width)

%  angle is clockwise from right horizont
%  eccentricity is from center to periphery

clear all;close all;
chb_x = 100;
chb_y = 100;
stripe_width = 10;

[x y] = meshgrid(-chb_x:chb_x, -chb_y:chb_y);

board1 = zeros(2*chb_y+1,2*chb_x+1);
board2 = board1;

ec = stripe_width;
ec_ex = 0;
trans = 1;

while board1(1,1) == 0
    board1 = board1 + (trans * ((x.^2 <= ec.^2)&(x.^2 >= ec_ex.^2)));
    ec = ec + stripe_width;
    ec_ex = ec_ex + stripe_width;
    trans = -trans;
end

ec = stripe_width;
ec_ex = 0;
trans = 1;

while board2(1,1) == 0
    board2 = board2 + (trans * ((y.^2 <= ec.^2)&(y.^2 >= ec_ex.^2)));
    ec = ec + stripe_width;
    ec_ex = ec_ex + stripe_width;
    trans = -trans;
end

checkerboard_temp = board1.*board2;
checkerboard = checkerboard_temp
% checkerboard(chb_y+1,chb_x+1) = 1;
end