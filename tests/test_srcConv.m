
try 
    purge
end

close all
clc
clear

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirSrc = fullfile(cDirThis, '..', 'src');
cDirMpm = fullfile(cDirThis, '..', 'mpm-packages');


addpath(cDirSrc);
addpath(cDirMpm);

cPath =  '/Users/cnanderson/Documents/Matlab/Code/matlab-pupil-fill-generator/ma_flare_psf.src';
[dX1, dY1, dI1] = readSrc(cPath);


cPath =  '/Users/cnanderson/Documents/Matlab/Code/matlab-pupil-fill-generator/tests/save/Grid_Dipole_ASML_offset160_rotation0_sizeOfGrid40_period300_filthz400_dt24_20181120-12272520190914-172903.src';
[dX2, dY2, dI2] = readSrc(cPath);


[dX, dY, dI] = convSrc(dX1, dY1, dI1, dX2, dY2, dI2, 251);

figure
imagesc(dX(1, :), dY(:, 1), dI)
axis image