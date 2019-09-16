

% Convolves two pupil fill srcs together and returns the output with a
% resolution of pixels (last param)
% @param {double 1xm} dX1 - list of sigmaX values of src1
% @param {double 1xm} dY1 - list of sigmaY values of src1
% @param {double 1xm} dI1 - list of relative intensity values of src1
% @param {double 1xm} dX2 - list of sigmaX values of src2
% @param {double 1xm} dY2 - list of sigmaY values of src2
% @param {double 1xm} dI2 - list of relative intensity values of src2
% @param {double 1x1} dPixels - number of pixels
% @return {double pixels * pixels} - sigmaX values of output
% @return {double pixels * pixels} - sigmaY values of output
% @return {double pixels * pixels} - intensity values of output
function [dX, dY, dI] = convSrc(dX1, dY1, dI1, dX2, dY2, dI2, dPixels)

dX = linspace(-1, 1, dPixels);
dY = dX;
[dX, dY] = meshgrid(dX, dY);

dI1Cart = griddata(...
    dX1, dY1, dI1, ...
    dX, ...
    dY ...
);

dI2Cart = griddata(...
    dX2, dY2, dI2, ...
    dX, ...
    dY ...
);

dI1Cart = dI1Cart ./ max(max(dI1Cart));
dI2Cart = dI2Cart ./ max(max(dI2Cart));


dI = conv2(dI1Cart, dI2Cart, 'same');
dI = dI ./ max(max(dI)); 

end
