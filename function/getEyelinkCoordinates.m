function [x, y] = getEyelinkCoordinates()
    sample = Eyelink('NewestFloatSample');
    if sample.gx(2)~=0 && sample.gy(2)~=0
        x = sample.gx(2);
        y = sample.gy(2);
    else
        x = nan;
        y = nan;
    end
end