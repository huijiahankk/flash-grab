function [radial_line_mat] = drawRadialLinesMat(radial_line_number,radial_line_length,startDistanceFromCenter);


radial_radius_inner = startDistanceFromCenter;%just an example
radial_theta_inner = linspace(0,2*pi,radial_line_number);%you can increase this if this isn't enough yet
radial_x_inner = radial_radius_inner * cos(radial_theta_inner);
radial_y_inner = radial_radius_inner * sin(radial_theta_inner);

radial_radius_outer = startDistanceFromCenter + 10 + radial_line_length;%just an example
radial_theta_outer = linspace(0,2*pi,radial_line_number);%you can increase this if this isn't enough yet
radial_x_outer = radial_radius_outer * cos(radial_theta_outer);
radial_y_outer = radial_radius_outer * sin(radial_theta_outer);


cycle = 1;
for k = 1:radial_line_number
    radial_line_mat_x(cycle) = radial_x_inner(k);
    radial_line_mat_x(cycle + 1) = radial_x_outer(k);
    radial_line_mat_y(cycle) = radial_y_inner(k);
    radial_line_mat_y(cycle + 1) = radial_y_outer(k);
    cycle = cycle + 2;
end

radial_line_mat = [radial_line_mat_x; radial_line_mat_y];
end