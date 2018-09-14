# matlab-pupil-fill-generator
MATLAB UI for generating monopole, dipole, quadrupole, disk, annular, auasar, and crosspole pupil fill waveforms suitable for use in active illumination systems of photolithography instruments with coherent sources.   This software is used by the Berkeley Extreme Ultraviolet (EUV) Microfield Exposure Tool (MET) at Lawrenece Berkeley National Lab.

# Installation

1. Clone this git repo into your MATLAB project, 
2. Clone the git repos of all [dependencies](#dependencies) into your project, preferably in a “vendor” directory.  If any dependencies have dependencies, be sure to bring those in too.  See [Recommended MATLAB App Structure](https://github.com/cnanders/matlab-app-structure)
3. Add the src code of this library and all dependencies to the MATLAB path, e.g., 
```matlab
addpath(genpath('vendor/github/cnanders/matlab-pupil-fill-generator/src'));
addpath(genpath('vendor/github/cnanders/matlab-instrument-control/src'));
addpath(genpath('vendor/github/cnanders/matlab-quasar/src'));
addpath(genpath('vendor/github/cnanders/matlab-gridded-pupil-fill/src'));

```
5. Instantiate a `PupilFillGenerator` and call its `build()` method

```matlab
sc = ScannerControl();
sc.build();
```

<a name="dependencies"></a>
## Dependencies

- [https://github.com/cnanders/matlab-quasar](https://github.com/cnanders/matlab-quasar)
- [https://github.com/cnanders/matlab-instrument-control](https://github.com/cnanders/matlab-instrument-control) for the UI (v1.1.0)


