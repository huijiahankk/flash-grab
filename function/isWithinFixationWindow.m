
function isWithin = isWithinFixationWindow(x, y, fixX, fixY, fixRadius)
    distance = sqrt((x-fixX)^2 + (y-fixY)^2);
    isWithin = distance <= fixRadius;
end