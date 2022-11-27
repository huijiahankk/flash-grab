function output = DrawRingWithBlurredBoundary(out_diameter,inner_diameter,black,white,ramp_slope,ramp_degree)

% out_diameter = 2000;
% inner_diameter = 1000;
% black = 0;
% white = 1;
% ramp_slope = 1;% 0~1
% ramp_degree = 5; % degrees

background = (white+black)/2;

[X, Y] = meshgrid(-out_diameter/2:out_diameter/2, -out_diameter/2:out_diameter/2);
output = background*ones(size(X));
scale = abs(1/(1+exp(-ramp_degree*ramp_slope)) - 1/(1+exp(ramp_degree*ramp_slope)));

for i = 1:length(output)
    for j = 1:length(output)
        if (X(i,j)^2 + Y(i,j)^2 >= (inner_diameter/2)^2)  &&  (X(i,j)^2 + Y(i,j)^2 <= (out_diameter/2)^2)
            
            % draw black-white ring
            if X(i,j) < 0
                output(i,j) = white;
            else
                output(i,j) = black;
            end
            
            if Y(i,j) > 0
            % draw blurred boundary
            angle = acosd( X(i,j)/((X(i,j)^2+Y(i,j)^2))^0.5) - 90;  
            if abs(angle) < ramp_degree
                output(i,j) = 1/(1+exp(-angle*ramp_slope));
                output(i,j) = (output(i,j) - white/2)/scale + white/2;
            end
            end
        end
    end
end


% imshow(output)

end