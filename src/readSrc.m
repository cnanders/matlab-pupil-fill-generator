

% Convolves two pupil fill srcs together and returns the output with a
% resolution of pixels (last param)
% @param {char 1xm} cPath - full path to the file
% @param {double 1x1} dPixels - number of pixels
% @return {double 1xm} - sigmaX values of output
% @return {double 1xm} - sigmaY values of output
% @return {double 1xm} - intensity values of output
function [dX, dY, dI] = readSrc(cPath)

    
fid = fopen(cPath, 'r');
cFormat = '%f,%f,%f';
c = textscan(fid, cFormat);

fclose(fid);

dX = c{1};
dY = c{2};
dI = c{3};
    
end
