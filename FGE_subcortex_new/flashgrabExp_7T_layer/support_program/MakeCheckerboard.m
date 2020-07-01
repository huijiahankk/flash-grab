function checkerboard = MakeCheckerboard(chb_x,chb_y, stripe_width, sector_width)

%  angle is clockwise from right horizont
%  eccentricity is from center to periphery

[x y] = meshgrid(-chb_x:chb_x, -chb_y:chb_y);

board1 = zeros(2*chb_y+1,2*chb_x+1);
board2 = board1;

ec = stripe_width;
ec_ex = 0;
trans = 1;

while board1(1,1) == 0
    board1 = board1 + (trans * ((x.^2+y.^2 <= ec^2)&(x.^2+y.^2 > ec_ex^2)));
    ec = ec + stripe_width;
    ec_ex = ec_ex + stripe_width;
    trans = -trans;
end

ag = -90+sector_width;
ag_ex = -90;

while ag_ex <= 90
    board2 = board2 + (trans * ((atand(y./x)>=ag_ex)&(atand(y./x)<ag)));
    ag = ag + sector_width;
    ag_ex = ag_ex + sector_width;
    trans = -trans;
end

checkerboard = board1.*board2;
checkerboard(chb_y+1,chb_x+1) = 1;

end
