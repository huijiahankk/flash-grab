function sectorDisc = MakeSectorDisc(chb_x, chb_y, sector_angle)

%% draw sector disc

clear all;close all;
chb_x = 100;
chb_y = 100;
sector_angle = 60;


[x y] = meshgrid(-chb_x:chb_x, -chb_y:chb_y);
board = zeros(2*chb_y+1,2*chb_x+1);

w = 180./sector_angle;

if mod(w,2) == 0
    ag = -90+sector_angle;
    ag_ex = -90;
    trans = 1;
    
    while ag_ex < 90
        board = board + trans.*((atand(y./x)>=ag_ex)&(atand(y./x)<ag));
        ag = ag + sector_angle;
        ag_ex = ag_ex + sector_angle;
        trans = -trans;
    end
else
    ag = -90+sector_angle;
    ag_ex = -90;
    trans = 1;
    
    while ag_ex < 90
        board = board + trans.*((atand(y./x)>=ag_ex)&(atand(y./x)<ag)&(x>0));
        ag = ag + sector_angle;
        ag_ex = ag_ex + sector_angle;
        trans = -trans;
    end
    
    ag = -90+sector_angle;
    ag_ex = -90;
    trans = -1;
    while ag_ex < 90
        board = board + trans.*((atand(y./x)>=ag_ex)&(atand(y./x)<ag)&(x<0));
        ag = ag + sector_angle;
        ag_ex = ag_ex + sector_angle;
        trans = -trans;
    end
end


sectorDisc = board;
sectorDisc(chb_y+1,chb_x+1) = 1;

end