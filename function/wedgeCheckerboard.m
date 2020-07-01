% draw tilt wedge checkerboard 

function cbColor = wedgeCheckerboard(alphaSectorMask,yCenter,wedgeBackColor,wedgeStripe_width,wedgeSector_width)

% [xCenter, yCenter]= RectCenter(ScreenRect);
[wedgeMat_m wedgeMat_n] = meshgrid(-yCenter:yCenter,-yCenter:yCenter);
mask_wedge(:,:,1) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(1);
mask_wedge(:,:,2) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(2);
mask_wedge(:,:,3) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(3);


checkerboard = MakeCheckerboard(yCenter,yCenter,wedgeStripe_width,wedgeSector_width);
cbColor(:,:,1) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,1);
cbColor(:,:,2) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,2);
cbColor(:,:,3) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,3);
cbColor(:,:,4) = alphaSectorMask;

end