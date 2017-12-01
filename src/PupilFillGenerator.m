classdef PupilFillGenerator < mic.Base


    properties (Constant)
        
        dPupilScale     = 1.1;
        dPupilPixels    = 220;
        
        dWidth          = 1230
        dHeight         = 650
        
        dWidthPanelPlot = 990;
        dWidthPanelSaved = 990;
        
        dWidthPanelBorder = 0
        dColorBgFigure = [200 200 200]./255;
        
        cQUASAR = 'Quasar'
        cMULTIPOLE = 'Multipole'
        cDC = 'DC'
        cRASTOR = 'Rastor'
        cSAW = 'Saw'
        cSERPENTINE = 'Serpentine'
    end
    
    properties
                
        
    end
    
    properties (SetAccess = private)
        
        
        
        dThetaX = 0; % deg
        dThetaY = 0;
        
        dHeightEdit = 24;
    end
    
    properties (Access = private)
           
        timerPreviewDebounce
        
        % {char 1xm} full path to the dir this file is in
        cDirThis
        % {char 1xm} full path to dir of the project
        cDirApp
        % { char 1xm} full path to dir of saved pupilfills
        cDirWaveforms
        
        cSaveDir
        
        cDevice = 'M142'       
        
        dYOffset = 360;
               
        hPanel
        hPanelWaveform
        hPanelWaveformMulti
        hPanelWaveformDC
        hPanelWaveformRastor
        hPanelWaveformSaw
        hPanelWaveformSerp
        hPanelWaveformQuasar
        hPanelWaveformGeneral
        hPanelSaved
        
        hPanelPlot   
        hAxis2D
        hAxis2DSim
        hAxis1D
        
        hLinesVxSensor1D
        hLinesVySensor1D
        hLinesVxCommand1D
        hLinesVyCommand1D
        
        hLinesSensorVxVsVy
        hLinesCommandVxVsVy
       
        
        hCameraPanel
        hDevicePanel
        
        lSerpentineDebug = false;
        hSerpentineKernelAxes
        hSerpentineWaveformAxes
        hSerpentineConvAxes
        hSerpentineConvOutputAxes
        hSerpentineCurrentAxes
        
        dPreviewPixels = 220;
        dPreviewScale = 1.1;
        
        
        dFreqMin        % minimum frequency
        dFreqMax        % maximum frequency
        
        dVx
        dVy
        dVxCorrected
        dVyCorrected
        dTime

        
        % Storage for record plot
        dRVxCommand
        dRVyCommand
        dRVxSensor
        dRVySensor
        dRTime
        
        uipType
        
        uiEditMultiPoleNum
        uiEditMultiSigMin
        uiEditMultiSigMax
        uiEditMultiCirclesPerPole
        uiEditMultiDwell
        uiEditMultiOffset
        uiEditMultiRot
        uiEditMultiXOffset
        uiEditMultiYOffset
        uiEditMultiTransitTime
        uiEditTimeStep
        uipMultiTimeType
        uiEditMultiHz
        uiEditMultiPeriod
        uitMultiFreqRange

        uiEditSawSigX
        uiEditSawPhaseX
        uiEditSawOffsetX
        uiEditSawSigY
        uiEditSawPhaseY
        uiEditSawOffsetY
        uipSawTimeType
        uiEditSawHz
        uiEditSawPeriod
        
        uiEditSerpSigX
        uiEditSerpSigY
        uiEditSerpNumX
        uiEditSerpNumY
        uiEditSerpOffsetX
        uiEditSerpOffsetY
        uiEditSerpPeriod
        
        uiEditQuasarRadiusInner
        uiEditQuasarRadiusOuter
        uiEditQuasarNumArcs
        uiEditQuasarNumPoles
        uiEditQuasarTheta
        uiEditQuasarPeriod
        uiEditQuasarRot
        uiEditQuasarOffsetX
        uiEditQuasarOffsetY
        
        uiEditDCx
        uiEditDCy
        
        uiEditRastorData
        uiEditRastorTransitTime
        uiListDirSaved
        
        uiEditFilterHz
        uiEditConvKernelSig
        
        uiButtonPreview
        uiButtonSave
                
    end
    
    events
        
        eNew
        eDelete
        
    end
    
    
    methods
        
        function this = PupilFillGenerator(varargin)
          
            [this.cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            
            this.cDirApp = this.cDirThis;
        
            this.cDirWaveforms = fullfile(...
                this.cDirApp, ...
                'save', ...
                sprintf('scanner-%s', this.cDevice) ...
            );
        
            % Apply varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            mic.Utils.checkDir(this.cDirWaveforms);
            
            this.init();
        end
            
         
        
        
        
        
        function build(this, hParent, dLeft, dTop)
        
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BackgroundColor', [200 200 200]./255, ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent)...
            );
            drawnow;
            
            
            
            if this.lSerpentineDebug
                figure
                this.hSerpentineKernelAxes = subplot(141);
                this.hSerpentineWaveformAxes = subplot(142);
                this.hSerpentineConvAxes = subplot(143);
                this.hSerpentineConvOutputAxes = subplot(144);
                drawnow;
                
                figure
                this.hSerpentineCurrentAxes = axes();
                drawnow;
                
                
            end
            
            this.buildPanelWaveform();
            this.buildPanelSaved();
            this.buildPanelPlot();
            
            % this.buildCameraPanel();
            % this.buildDevicePanel();
            % this.np.build(this.hPanel, 750 + 160, this.dYOffset);
            
            this.uiListDirSaved.refresh();
            
            % this.onListChange();
            this.preview();
        end
        
        function delete(this)
           
            this.msg('delete');
            % Delete the figure
            
            % Get properties:
            ceProperties = properties(this);
            
            % Loop through properties:
            for k = 1:length(ceProperties)
                if  isobject(this.(ceProperties{k}))  && ... 
                    ishandle(this.(ceProperties{k}))
                delete(this.(ceProperties{k}));
                end
            end
                                   
        end
               
        function st = save(this)
            st = struct();
        	st.uiListDirSaved = this.uiListDirSaved.save();
        end
        
        function load(this, st)
            this.uiListDirSaved.load(st.uiListDirSaved);
        end
        
        % @typedef {struct 1x1} PupilFillData
        % @property {double 1xm} x - x amplitude [0 : 1]
        % @property {double 1xm} y - y amplitude [0 : 1]
        % @property {double 1xm} t - time (sec)
        
        % @return {PupilFillData 1x1}
        function st = get(this)
            st = struct();
            st.x = this.dVx;
            st.y = this.dVy;
            st.t = this.dTime;
        end
        

    end
    
    methods (Access = private)
        
        function loadPanelWaveformState(this, st)
           
             this.uipType.load(st.uipType);

             this.uiEditMultiPoleNum.load(st.uiEditMultiPoleNum);
             this.uiEditMultiSigMin.load(st.uiEditMultiSigMin);
             this.uiEditMultiSigMax.load(st.uiEditMultiSigMax);
             this.uiEditMultiCirclesPerPole.load(st.uiEditMultiCirclesPerPole);
             this.uiEditMultiDwell.load(st.uiEditMultiDwell);  
             this.uiEditMultiOffset.load(st.uiEditMultiOffset);
             this.uiEditMultiRot.load(st.uiEditMultiRot);
             this.uiEditMultiXOffset.load(st.uiEditMultiXOffset);
             this.uiEditMultiYOffset.load(st.uiEditMultiYOffset);
             this.uiEditMultiTransitTime.load(st.uiEditMultiTransitTime);
             this.uiEditTimeStep.load(st.uiEditTimeStep);
             this.uipMultiTimeType.load(st.uipMultiTimeType);
             this.uiEditMultiHz.load(st.uiEditMultiHz);
             this.uiEditMultiPeriod.load(st.uiEditMultiPeriod);
 
             this.uiEditSawSigX.load(st.uiEditSawSigX);
             this.uiEditSawPhaseX.load(st.uiEditSawPhaseX);
             this.uiEditSawOffsetX.load(st.uiEditSawOffsetX);
             this.uiEditSawSigY.load(st.uiEditSawSigY);
             this.uiEditSawPhaseY.load(st.uiEditSawPhaseY);
             this.uiEditSawOffsetY.load(st.uiEditSawOffsetY);
             this.uipSawTimeType.load(st.uipSawTimeType);
             this.uiEditSawHz.load(st.uiEditSawHz);
             this.uiEditSawPeriod.load(st.uiEditSawPeriod);

             this.uiEditSerpSigX.load(st.uiEditSerpSigX);
             this.uiEditSerpSigY.load(st.uiEditSerpSigY);
             this.uiEditSerpNumX.load(st.uiEditSerpNumX);
             this.uiEditSerpNumY.load(st.uiEditSerpNumY);
             this.uiEditSerpOffsetX.load(st.uiEditSerpOffsetX);
             this.uiEditSerpOffsetY.load(st.uiEditSerpOffsetY);
             this.uiEditSerpPeriod.load(st.uiEditSerpPeriod);
             
             if isfield(st, 'uiEditQuasarRadiusInner')
                 this.uiEditQuasarRadiusInner.load(st.uiEditQuasarRadiusInner);
                 this.uiEditQuasarRadiusOuter.load(st.uiEditQuasarRadiusOuter);
                 this.uiEditQuasarNumArcs.load(st.uiEditQuasarNumArcs);
                 this.uiEditQuasarNumPoles.load(st.uiEditQuasarNumPoles);
                 this.uiEditQuasarTheta.load(st.uiEditQuasarTheta);
                 this.uiEditQuasarRot.load(st.uiEditQuasarRot);
                 this.uiEditQuasarOffsetX.load(st.uiEditQuasarOffsetX);
                 this.uiEditQuasarOffsetY.load(st.uiEditQuasarOffsetY);
                 this.uiEditQuasarPeriod.load(st.uiEditQuasarPeriod);
             end


             this.uiEditDCx.load(st.uiEditDCx);
             this.uiEditDCy.load(st.uiEditDCy);

             this.uiEditRastorData.load(st.uiEditRastorData);
             this.uiEditRastorTransitTime.load(st.uiEditRastorTransitTime);

             this.uiEditFilterHz.load(st.uiEditFilterHz);
             this.uiEditConvKernelSig.load(st.uiEditConvKernelSig);
             
            
        end
        
        function st = savePanelWaveformState(this)
            
            st = struct();
            
            st.uipType = this.uipType.save();

            st.uiEditMultiPoleNum = this.uiEditMultiPoleNum.save();
            st.uiEditMultiSigMin = this.uiEditMultiSigMin.save();
            st.uiEditMultiSigMax = this.uiEditMultiSigMax.save();
            st.uiEditMultiCirclesPerPole = this.uiEditMultiCirclesPerPole.save();
            st.uiEditMultiDwell = this.uiEditMultiDwell.save();  
            st.uiEditMultiOffset = this.uiEditMultiOffset.save();
            st.uiEditMultiRot = this.uiEditMultiRot.save();
            st.uiEditMultiXOffset = this.uiEditMultiXOffset.save();
            st.uiEditMultiYOffset =  this.uiEditMultiYOffset.save();
            st.uiEditMultiTransitTime = this.uiEditMultiTransitTime.save();
            st.uiEditTimeStep = this.uiEditTimeStep.save();
            st.uipMultiTimeType = this.uipMultiTimeType.save();
            st.uiEditMultiHz = this.uiEditMultiHz.save();
            st.uiEditMultiPeriod = this.uiEditMultiPeriod.save();
 
            st.uiEditSawSigX = this.uiEditSawSigX.save();
            st.uiEditSawPhaseX = this.uiEditSawPhaseX.save();
            st.uiEditSawOffsetX = this.uiEditSawOffsetX.save();
            st.uiEditSawSigY = this.uiEditSawSigY.save();
            st.uiEditSawPhaseY = this.uiEditSawPhaseY.save();
            st.uiEditSawOffsetY = this.uiEditSawOffsetY.save();
            st.uipSawTimeType = this.uipSawTimeType.save();
            st.uiEditSawHz = this.uiEditSawHz.save();
            st.uiEditSawPeriod = this.uiEditSawPeriod.save();

            st.uiEditSerpSigX = this.uiEditSerpSigX.save();
            st.uiEditSerpSigY = this.uiEditSerpSigY.save();
            st.uiEditSerpNumX = this.uiEditSerpNumX.save();
            st.uiEditSerpNumY = this.uiEditSerpNumY.save();
            st.uiEditSerpOffsetX = this.uiEditSerpOffsetX.save();
            st.uiEditSerpOffsetY = this.uiEditSerpOffsetY.save();
            st.uiEditSerpPeriod = this.uiEditSerpPeriod.save();
            
            st.uiEditQuasarRadiusInner = this.uiEditQuasarRadiusInner.save();
            st.uiEditQuasarRadiusOuter = this.uiEditQuasarRadiusOuter.save();
            st.uiEditQuasarNumArcs = this.uiEditQuasarNumArcs.save();
            st.uiEditQuasarNumPoles = this.uiEditQuasarNumPoles.save();
            st.uiEditQuasarTheta = this.uiEditQuasarTheta.save();
            st.uiEditQuasarRot = this.uiEditQuasarRot.save();
            st.uiEditQuasarOffsetX = this.uiEditQuasarOffsetX.save();
            st.uiEditQuasarOffsetY = this.uiEditQuasarOffsetY.save();
            st.uiEditQuasarPeriod = this.uiEditQuasarPeriod.save();

            st.uiEditDCx = this.uiEditDCx.save();
            st.uiEditDCy = this.uiEditDCy.save();

            st.uiEditRastorData = this.uiEditRastorData.save();
            st.uiEditRastorTransitTime = this.uiEditRastorTransitTime.save();

            st.uiEditFilterHz = this.uiEditFilterHz.save();
            st.uiEditConvKernelSig = this.uiEditConvKernelSig.save();
        end
        
        function initPanelWaveformQuasar(this)
            
            this.uiEditQuasarRadiusInner = mic.ui.common.Edit(...
                'cLabel', 'Radius Inner', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty ...
            ); 
            this.uiEditQuasarRadiusInner.setMin(0);
            this.uiEditQuasarRadiusInner.setMax(1);
            this.uiEditQuasarRadiusInner.set(0.5);
            
            
            this.uiEditQuasarRadiusOuter = mic.ui.common.Edit(...
                'cLabel', 'Radius Outer', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty ...
            ); 
            this.uiEditQuasarRadiusOuter.setMin(0);
            this.uiEditQuasarRadiusOuter.setMax(1);
            this.uiEditQuasarRadiusOuter.set(0.7);
            
            this.uiEditQuasarNumArcs = mic.ui.common.Edit(...
                'cLabel', 'Arcs Per Pole', ...
                'cType', 'u8', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarNumArcs.set(uint8(9));
            this.uiEditQuasarNumArcs.setMin(uint8(3));
            
            this.uiEditQuasarNumPoles = mic.ui.common.Edit(...
                'cLabel', 'Num Poles', ...
                'cType', 'u8', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarNumPoles.set(uint8(4));
            this.uiEditQuasarNumPoles.setMin(uint8(1));
            
            
            this.uiEditQuasarTheta = mic.ui.common.Edit(...
                'cLabel', 'Pole Angle (deg)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarTheta.setMin(0);
            this.uiEditQuasarTheta.setMax(360);
            this.uiEditQuasarTheta.set(30);
            
            this.uiEditQuasarPeriod = mic.ui.common.Edit(...
                'cLabel', 'Period (ms)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarPeriod.setMin(0);
            this.uiEditQuasarPeriod.set(200);
            
            this.uiEditQuasarRot = mic.ui.common.Edit(...
                'cLabel', 'Rot (deg)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarRot.setMin(-360);
            this.uiEditQuasarRot.setMax(360);
            this.uiEditQuasarRot.set(0);
            
            this.uiEditQuasarOffsetX = mic.ui.common.Edit(...
                'cLabel', 'Offset X', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarOffsetX.setMin(0);
            this.uiEditQuasarOffsetX.setMax(1);
            this.uiEditQuasarOffsetX.set(0);
            
            this.uiEditQuasarOffsetY = mic.ui.common.Edit(...
                'cLabel', 'Offset Y', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditQuasarOffsetY.setMin(0);
            this.uiEditQuasarOffsetY.setMax(1);
            this.uiEditQuasarOffsetY.set(0);
            
        end
        
        
        function initPanelWaveformSerp(this)
            
            this.uiEditSerpSigX = mic.ui.common.Edit(...
                'cLabel', 'Sig X', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditSerpSigX.setMin(0);
            this.uiEditSerpSigX.setMax(1);
            this.uiEditSerpSigX.set(0.5);
            
            this.uiEditSerpNumX = mic.ui.common.Edit(...
                'cLabel', 'Num X (odd)', ...
                'cType', 'u8', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSerpNumX.set(uint8(7));
            this.uiEditSerpNumX.setMin( uint8(4));
            this.uiEditSerpNumX.setMax( uint8(51));
            
            this.uiEditSerpOffsetX = mic.ui.common.Edit(...
                'cLabel', 'Offset X', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSerpOffsetX.setMin(-1);
            this.uiEditSerpOffsetX.setMax(1);
            
            this.uiEditSerpSigY = mic.ui.common.Edit(...
                'cLabel', 'Sig Y', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditSerpSigY.setMin(0);
            this.uiEditSerpSigY.setMax(1);
            this.uiEditSerpSigY.set(0.5);            
            
            this.uiEditSerpNumY = mic.ui.common.Edit(...
                'cLabel', 'Num Y (odd)', ...
                'cType', 'u8', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSerpNumY.set(uint8(7));
            this.uiEditSerpNumY.setMin( uint8(4));
            this.uiEditSerpNumY.setMax( uint8(51));
            
            this.uiEditSerpOffsetY = mic.ui.common.Edit(...
                'cLabel', 'Offset Y', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSerpOffsetY.setMin(-1);
            this.uiEditSerpOffsetY.setMax(1);
            
            this.uiEditSerpPeriod = mic.ui.common.Edit(...
                'cLabel', 'Period (ms)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSerpPeriod.set(100); 
            this.uiEditSerpPeriod.setMin( 1);
            this.uiEditSerpPeriod.setMax( 10000);
            
        end
        
        function initPanelWaveformSaw(this)
            
            this.uiEditSawSigX = mic.ui.common.Edit(...
                'cLabel', 'Sig X', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditSawSigX.setMin(0);
            this.uiEditSawSigX.setMax(1);
            this.uiEditSawSigX.set(0.5);
            
            this.uiEditSawPhaseX = mic.ui.common.Edit(...
                'cLabel', 'Phase X (pi)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawPhaseX.setMin(-2);
            this.uiEditSawPhaseX.setMax(2);
                        
            this.uiEditSawOffsetX = mic.ui.common.Edit(...
                'cLabel', 'Offset X', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawOffsetX.setMin(-1);
            this.uiEditSawOffsetX.setMax(1);
            
            this.uiEditSawSigY = mic.ui.common.Edit(...
                'cLabel', 'Sig Y', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty); 
            this.uiEditSawSigY.setMin(0);
            this.uiEditSawSigY.setMax(1);
            this.uiEditSawSigY.set(0.5);            
            
            this.uiEditSawPhaseY = mic.ui.common.Edit(...
                'cLabel', 'Phase Y (pi)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawPhaseY.setMin(-2);
            this.uiEditSawPhaseY.setMax(2);
                        
            this.uiEditSawOffsetY = mic.ui.common.Edit(...
                'cLabel', 'Offset Y', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawOffsetY.setMin(-1);
            this.uiEditSawOffsetY.setMax(1);
                                    
            this.uipSawTimeType = mic.ui.common.Popup(...
                'ceOptions', {'Period (ms)', 'Hz (avg)'}, ...
                'cLabel', 'Select Time Type', ...
                'fhDirectCallback', @this.onWaveformProperty);
            addlistener(this.uipSawTimeType, 'eChange', @this.onSawTimeTypeChange);            
            
            this.uiEditSawHz = mic.ui.common.Edit(...
                'cLabel', 'Hz (avg)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawHz.setMin(0);
            this.uiEditSawHz.setMax(1000);
            this.uiEditSawHz.set(200);
            
            this.uiEditSawPeriod = mic.ui.common.Edit(...
                'cLabel', 'Period (ms)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditSawPeriod.set(100); 
            this.uiEditSawPeriod.setMin(1);
            this.uiEditSawPeriod.setMax(10000);
            
        end
        
        function initPanelWaveformRastor(this)
            
             
            this.uiEditRastorData = mic.ui.common.Edit(...
                'cLabel', '(sig_x,sig_y,ms),(sig_x,sig_y,ms),...', ...
                'cType', 'c', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditRastorTransitTime =     mic.ui.common.Edit(...
                'cLabel', 'Transit Time (s)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            
            this.uiEditRastorData.set('(0.3,0.3,5),(0.5,0.5,10),(0.4,0.4,4)');

           
            
        end
        
        function initPanelWaveformDC(this)
           
            this.uiEditDCx = mic.ui.common.Edit(...
                'cLabel', 'X offset', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditDCy = mic.ui.common.Edit(...
                'cLabel', 'Y offset', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            
            this.uiEditDCx.set(0.5);
            this.uiEditDCy.set(0.3);
        end
        
        function initPanelWaveformMulti(this)
            
            this.uiEditMultiPoleNum = mic.ui.common.Edit(...
                'cLabel', 'Poles', ...
                'cType', 'u8', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiSigMin = mic.ui.common.Edit(...
                'cLabel', 'Sig min', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiSigMax = mic.ui.common.Edit(...
                'cLabel', 'Sig max', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiCirclesPerPole =   mic.ui.common.Edit(...
                'cLabel', 'Circles/pole', ...
                'cType',  'u8', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiDwell = mic.ui.common.Edit(...
                'cLabel', 'Dwell', ...
                'cType',  'u8', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiOffset = mic.ui.common.Edit(...
                'cLabel', 'Pole Offset', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiRot = mic.ui.common.Edit(...
                'cLabel', 'Rot', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiXOffset = mic.ui.common.Edit(...
                'cLabel', 'X Global Offset', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiYOffset = mic.ui.common.Edit(...
                'cLabel', 'Y Global Offset', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);

            this.uiEditMultiTransitTime = mic.ui.common.Edit(...
                'cLabel', 'Transit Frac', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            
            this.uipMultiTimeType = mic.ui.common.Popup(...
                'ceOptions', {'Period (ms)', 'Hz (avg)'}, ...
                'cLabel', 'Select Time Type');
            addlistener(this.uipMultiTimeType, 'eChange', @this.onMultiTimeTypeChange);            
            
            this.uiEditMultiPeriod = mic.ui.common.Edit(...
                'cLabel', 'Period (ms)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditMultiHz = mic.ui.common.Edit(...
                'cLabel', 'Hz (avg)', ...
                'cType',  'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uitMultiFreqRange = mic.ui.common.Text('cVal', '');
            
            % Defaults
            this.uiEditMultiPoleNum.set(uint8(4));
            this.uiEditMultiSigMin.set(0.2);
            this.uiEditMultiSigMax.set(0.3);
            this.uiEditMultiCirclesPerPole.set(uint8(2));
            this.uiEditMultiDwell.set(uint8(2));
            this.uiEditMultiOffset.set(0.6);
            this.uiEditMultiTransitTime.set(0.08);
            this.uiEditMultiHz.set(200);
            this.uiEditMultiPeriod.set(100);
            
            
        end
        
        function initPanelWaveformGeneral(this)
            
            % *********** General waveform panel
            
            this.uiEditFilterHz = mic.ui.common.Edit(...
                'cLabel', 'Filter Hz', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditFilterHz.set(400);
            this.uiEditFilterHz.setMin(1);
            this.uiEditFilterHz.setMax(10000);
            
            
            this.uiEditTimeStep = mic.ui.common.Edit(...
                'cLabel', 'Time step (us)', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditTimeStep.set(24);    % nPoint has a 24 us control loop
            
            
            this.uiEditConvKernelSig = mic.ui.common.Edit(...
                'cLabel', 'Conv. kernel sig', ...
                'cType', 'd', ...
                'fhDirectCallback', @this.onWaveformProperty);
            this.uiEditConvKernelSig.set(0.05);
            this.uiEditConvKernelSig.setMin(0.01);
            this.uiEditConvKernelSig.setMax(1);
            
        end
        
        function initPanelWaveform(this)
            
            this.uipType = mic.ui.common.Popup(...
                'ceOptions', {...
                    this.cQUASAR, ...
                    this.cMULTIPOLE, ...
                    this.cDC, ...
                    this.cRASTOR, ...
                    this.cSAW, ...
                    this.cSERPENTINE ...
                 }, ...                
                'cLabel', 'Type');
            addlistener(this.uipType, 'eChange', @this.onTypeChange);
            
            
            this.initPanelWaveformGeneral();
            this.initPanelWaveformMulti();
            this.initPanelWaveformDC();
            this.initPanelWaveformRastor();
            this.initPanelWaveformSaw();
            this.initPanelWaveformSerp();
            this.initPanelWaveformQuasar();
            
            this.uiButtonPreview = mic.ui.common.Button(...
                'cText', 'Preview');
            this.uiButtonSave = mic.ui.common.Button(...
                'cText', 'Save');
            
            addlistener(this.uiButtonPreview, 'eChange', @this.onPreview);
            addlistener(this.uiButtonSave, 'eChange', @this.onSave);
            
        end
        
        function initPanelSaved(this)
                        
            this.uiListDirSaved = mic.ui.common.ListDir(...
                'cDir', this.cDirWaveforms, ...
                'cFilter', '*.mat', ...
                'fhOnChange', @this.onListChange, ...
                'lShowDelete', true, ...
                'lShowMove', false, ...
                'lShowLabel', false ...
            );    
        end
        
        
        function initTimerPreviewDebounce(this)
            
            this.timerPreviewDebounce = timer;
            this.timerPreviewDebounce.StartDelay = 0.1;
            this.timerPreviewDebounce.TimerFcn = @this.previewDebounced;
            
        end
        
        
        function init(this)
                    
            this.initTimerPreviewDebounce()
            this.initPanelWaveform();
            this.initPanelSaved();
                                    
        end
        
        
        
       
        
        
        
        
                
        function onMultiTimeTypeChange(this, src, evt)
            
                                                
            % Show the UIEdit based on popup type 
            switch this.uipMultiTimeType.getSelectedIndex()
                case uint8(1)
                    % Period
                    if this.uiEditMultiHz.isVisible()
                        this.uiEditMultiHz.hide();
                    end
                    
                    if ~this.uiEditMultiPeriod.isVisible()
                        this.uiEditMultiPeriod.show();
                    end
                    
                case uint8(2)
                    % Hz
                    if this.uiEditMultiPeriod.isVisible()
                        this.uiEditMultiPeriod.hide();
                    end
                    
                    if ~this.uiEditMultiHz.isVisible()
                        this.uiEditMultiHz.show();
                    end
            end    
        end

        
        function onSawTimeTypeChange(this, src, evt)
            
            
            % Show the UIEdit based on popup type
            
            switch this.uipSawTimeType.getSelectedIndex()
                case uint8(1)
                    % Period
                    if this.uiEditSawHz.isVisible()
                        this.uiEditSawHz.hide();
                    end
                    
                    if ~this.uiEditSawPeriod.isVisible()
                        this.uiEditSawPeriod.show();
                    end
                    
                case uint8(2)
                    % Hz
                    if this.uiEditSawPeriod.isVisible()
                        this.uiEditSawPeriod.hide();
                    end
                    
                    if ~this.uiEditSawHz.isVisible()
                        this.uiEditSawHz.show();
                    end
            end
            
            
        end
        
        function onTypeChange(this, src, evt)
            
            
            % Build the sub-panel based on popup type 
            switch this.uipType.getSelectedValue()
                case this.cMULTIPOLE
                    this.hideOtherPanelWaveforms(this.hPanelWaveformMulti);
                    if ishandle(this.hPanelWaveformMulti)
                        set(this.hPanelWaveformMulti, 'Visible', 'on');
                    else
                        this.buildPanelWaveformMulti();
                    end
                    
                case this.cDC
                    this.hideOtherPanelWaveforms(this.hPanelWaveformDC);
                    if ishandle(this.hPanelWaveformDC)
                        set(this.hPanelWaveformDC, 'Visible', 'on');
                    else
                        this.buildPanelWaveformDC();
                    end
                case this.cRASTOR
                    this.hideOtherPanelWaveforms(this.hPanelWaveformRastor);
                    if ishandle(this.hPanelWaveformRastor)
                        set(this.hPanelWaveformRastor, 'Visible', 'on');
                    else
                        this.buildPanelWaveformRastor();
                    end
                case this.cSAW
                    this.hideOtherPanelWaveforms(this.hPanelWaveformSaw);
                    if ishandle(this.hPanelWaveformSaw)
                        set(this.hPanelWaveformSaw, 'Visible', 'on');
                    else
                        this.buildPanelWaveformSaw();
                    end
                case this.cSERPENTINE
                    this.hideOtherPanelWaveforms(this.hPanelWaveformSerp);
                    if ishandle(this.hPanelWaveformSerp)
                        set(this.hPanelWaveformSerp, 'Visible', 'on');
                    else
                        this.buildPanelWaveformSerp();
                    end
                case this.cQUASAR
                    this.hideOtherPanelWaveforms(this.hPanelWaveformQuasar);
                    if ishandle(this.hPanelWaveformQuasar)
                        set(this.hPanelWaveformQuasar, 'Visible', 'on');
                    else
                        this.buildPanelWaveformQuasar();
                    end
                    
            end
            
            this.preview()
        end
        
        
        function hideOtherPanelWaveforms(this, h)
            
            % @parameter h
            %   type: handle
            %   desc: handle of the panel that you don't want to hide
            
            % USE CAUTION!  h may be empty when we pass it in
            
            %{
            this.msg( ...
                sprintf( ...
                    'PupilFill.hideOtherPanelWaveforms() \n\t %1.0f', ...
                    h ...
                ) ...
            );
            %}
            
            % cell of handles of each waveform panel
            ceh = { ...
                this.hPanelWaveformMulti, ...
                this.hPanelWaveformDC, ...
                this.hPanelWaveformRastor, ...
                this.hPanelWaveformSaw, ...
                this.hPanelWaveformSerp, ...
                this.hPanelWaveformQuasar ...
            };
            
            % loop through all panels
            for n = 1:length(ceh)            
                
                ceOptions = this.uipType.getOptions();
                %{
                this.msg( ...
                    sprintf( ...
                        'PupilFill.hideOtherPanelWaveforms() \n\t panel: %s \n\t ishandle: %1.0f \n\t handleval: %1.0f \n\t visible: %s \n\t isequal: %1.0f ', ...
                        ceOptions{uint8(n)}, ...
                        +ishandle(ceh{n}), ...
                        ceh{n}, ...
                        get(ceh{n}, 'Visible'), ...
                        +(ceh{n} ~= h) ...
                    ) ...
                );
                %}
                
                if ishandle(ceh{n}) & ...
                   strcmp(get(ceh{n}, 'Visible'), 'on') & ...
                   (isempty(h) | ceh{n} ~= h)
                    ceOptions = this.uipType.getOptions();
                    this.msg(sprintf('PupilFill.hideOtherPanelWaveforms() hiding %s panel', ceOptions{uint8(n)}));
                    set(ceh{n}, 'Visible', 'off');
                    
                end
            end
            
        end
        
        function hidePanelWaveforms(this)
                           
            if ishandle(this.hPanelWaveformMulti)
                set(this.hPanelWaveformMulti, 'Visible', 'off');
            end
            
            if ishandle(this.hPanelWaveformDC)
                set(this.hPanelWaveformDC, 'Visible', 'off');
            end
            
            if ishandle(this.hPanelWaveformRastor)
                set(this.hPanelWaveformRastor, 'Visible', 'off');
            end
            
            if ishandle(this.hPanelWaveformSaw)
                set(this.hPanelWaveformSaw, 'Visible', 'off');
            end
            
            drawnow;
            
        end
        
        function onWaveformProperty(this, src, evt)
            this.preview()
        end
        
        function preview(this)
            
            fprintf('PupilFillGenerator preview() \n');
            
            if strcmp(this.timerPreviewDebounce.Running, 'on')
                % Restart
                stop(this.timerPreviewDebounce);
                start(this.timerPreviewDebounce);
            else
                start(this.timerPreviewDebounce); 
            end
            
        end
        
        function previewDebounced(this, src, evt)
            
            fprintf('PupilFillGenerator previewDebounced() \n');
            % Build in debouncing to preview
            this.updateWaveforms();
            this.updateAxes();
            this.updatePupilImg();
            
            switch this.uipType.getSelectedValue()
                case this.cMULTIPOLE
                    
                    % Update multi range

                    % The piezos have a voltage range between -30V and 150V
                    % 180V is the full swing to achieve 6 mrad
                    % +/- 90V = +/- sig = 1.
                    % The current across a capacitor is: I = C*dV/dt 
                    % The "small signal" capacitance of the piezo stack is about 2e-6 F (C/V).  
                    % Source http://trs-new.jpl.nasa.gov/dspace/bitstream/2014/41642/1/08-0299.pdf
                    % At full range, the voltage signal is: V(t) = 90*sin(2*pi*f*t)
                    % dV/dt = 90*2*pi*f*cos(2*pi*f*t) which has a max of 180*pi*f V/s   
                    % At 100 Hz, this is 180*100*pi V/s * 2e-6 (C/V) = 113 mA.  
                    % It is believed that capacitance increases to 2.5e-6 F bit
                    % for large signal which brings current up to 140 mA


                    % Min frequency occurs at max sig and visa versa
                    dC = 2e-6; % advertised
                    dC_scale_factor = 300/113;

                    dVdt_sig_max = 2*pi*90*this.uiEditMultiSigMax.get()*this.dFreqMin;
                    dVdt_sig_min = 2*pi*90*this.uiEditMultiSigMin.get()*this.dFreqMax;
                    dI_sig_max = dC*dC_scale_factor*dVdt_sig_max*1000; % mA
                    dI_sig_min = dC*dC_scale_factor*dVdt_sig_min*1000; % mA

                    cMsg = sprintf('Freq: %1.0f Hz - %1.0f Hz.\nI: %1.0f mA - %1.0f mA', ...
                        this.dFreqMin, ...
                        this.dFreqMax, ...
                        dI_sig_min, ...
                        dI_sig_max ...
                        );

                    this.uitMultiFreqRange.set(cMsg);
            end
        end
        
        
        function onPreview(this, src, evt)
            this.preview()
        end
        
        function updateWaveforms(this)
            
            % Update:
            % 
            %   dVx, 
            %   dVy, 
            %   dVxCorrected, 
            %   dVyCorrected, 
            %   dTime 

            %
            % and update plot preview
            
            switch this.uipType.getSelectedValue()
                case this.cMULTIPOLE
                    
                    % Show the UIEdit based on popup type 
                    switch this.uipMultiTimeType.getSelectedIndex()
                        case uint8(1)
                            % Period
                            lPeriod = true;

                        case uint8(2)
                            % Hz
                            lPeriod = false;
                    end
                    
                    
                    [this.dVx, ...
                     this.dVy, ...
                     this.dVxCorrected, ...
                     this.dVyCorrected, ...
                     this.dTime, ...
                     this.dFreqMin, ...
                     this.dFreqMax] = ScannerCore.getMulti( ...
                        double(this.uiEditMultiPoleNum.get()), ...
                        this.uiEditMultiSigMin.get(), ...
                        this.uiEditMultiSigMax.get(), ...
                        double(this.uiEditMultiCirclesPerPole.get()), ...
                        double(this.uiEditMultiDwell.get()), ...
                        this.uiEditMultiTransitTime.get(), ...
                        this.uiEditMultiOffset.get(), ...
                        this.uiEditMultiRot.get(), ...
                        this.uiEditMultiXOffset.get(), ...
                        this.uiEditMultiYOffset.get(), ...
                        this.uiEditMultiHz.get(), ...
                        1, ...
                        this.uiEditTimeStep.get()*1e-6, ...         
                        this.uiEditFilterHz.get(), ... 
                        this.uiEditMultiPeriod.get()/1000, ...
                        lPeriod ...
                        );
                    
                case this.cDC
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = ScannerCore.getDC( ...
                        this.uiEditDCx.get(), ...
                        this.uiEditDCy.get(),...
                        1, ...
                        this.uiEditTimeStep.get()*1e-6 ...         
                        );
                    
                case this.cRASTOR
                    
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = ScannerCore.getRastor( ...
                        this.uiEditRastorData.get(), ...
                        this.uiEditRastorTransitTime.get(), ...
                        this.uiEditTimeStep.get(), ... % send in us, not s
                        1, ...
                        this.uiEditFilterHz.get() ...
                        );
                    
                case this.cSAW
                    
                    if this.uipSawTimeType.getSelectedIndex() == uint8(1)
                        % Period (ms)
                        dHz = 1/(this.uiEditSawPeriod.get()/1e3);
                    else
                        % Hz
                        dHz = this.uiEditSawHz.get();
                    end
                    
                    st = ScannerCore.getSaw( ...
                        this.uiEditSawSigX.get(), ...
                        this.uiEditSawPhaseX.get(), ...
                        this.uiEditSawOffsetX.get(), ...
                        this.uiEditSawSigY.get(), ...
                        this.uiEditSawPhaseY.get(), ...
                        this.uiEditSawOffsetY.get(), ...
                        1, ...
                        dHz, ...
                        this.uiEditFilterHz.get(), ...
                        this.uiEditTimeStep.get()*1e-6 ...
                        );
                    
                    this.dVx = st.dX;
                    this.dVy = st.dY;
                    this.dTime = st.dT;
                    
                case this.cSERPENTINE
                                        
                    st = ScannerCore.getSerpentine2( ...
                        this.uiEditSerpSigX.get(), ...
                        this.uiEditSerpSigY.get(), ...
                        this.uiEditSerpNumX.get(), ...
                        this.uiEditSerpNumY.get(), ...
                        this.uiEditSerpOffsetX.get(), ...
                        this.uiEditSerpOffsetY.get(), ...
                        this.uiEditSerpPeriod.get()*1e-3, ...
                        1, ...
                        this.uiEditFilterHz.get(), ...
                        this.uiEditTimeStep.get()*1e-6 ...
                        );
                    
                    this.dVx = st.dX;
                    this.dVy = st.dY;
                    this.dTime = st.dT;
                    
                case this.cQUASAR
                    
                    st = quasar(...
                        'radiusPoleInner', this.uiEditQuasarRadiusInner.get(), ...
                        'radiusPoleOuter', this.uiEditQuasarRadiusOuter.get(), ...
                        'numArcs', this.uiEditQuasarNumArcs.get(), ...
                        'numPoles', this.uiEditQuasarNumPoles.get(), ...
                        'theta', this.uiEditQuasarTheta.get(), ...
                        'period', this.uiEditQuasarPeriod.get() / 1000, ...
                        'dt', this.uiEditTimeStep.get() * 1e-6 ...
                   );
               
                   x = st.x;
                   y = st.y;
                   t = st.t;
                   
                   % Rotate
                   [theta, rho] = cart2pol(x, y);
                   theta = theta + this.uiEditQuasarRot.get() * pi / 180;
                   [x, y] = pol2cart(theta, rho);
                   
                   % Filter
                   x = ScannerCore.lowpass(x, t, this.uiEditFilterHz.get());
                   y = ScannerCore.lowpass(y, t, this.uiEditFilterHz.get());
            
                   this.dVx = x;
                   this.dVy = y;
                   this.dTime = st.t;
                                        
            end
            
            
            
            
                        
        end
        
        function updateAxes(this)
                        
            if ishandle(this.hPanel) & ... 
               ishandle(this.hAxis2D) & ...
               ishandle(this.hAxis1D)

                % set(this.hPanel, 'CurrentAxes', this.hAxis2D)
                plot(...
                    this.hAxis2D, ...
                    this.dVx, this.dVy, 'b' ...
                );
                xlim(this.hAxis2D, [-1 1])
                ylim(this.hAxis2D, [-1 1])

                % set(this.hPanel, 'CurrentAxes', this.hAxis1D)
                plot(...
                    this.hAxis1D, ...
                    this.dTime*1000, this.dVx, 'r', ...
                    this.dTime*1000, this.dVy,'b' ...
                );
                xlabel(this.hAxis1D, 'Time [ms]')
                ylabel(this.hAxis1D, 'Amplitude')
                % title(this.hAxis1D, this.cTitlePreview);
                legend(this.hAxis1D, 'ch1 (x)','ch2 (y)')
                xlim(this.hAxis1D, [0 max(this.dTime*1000)])
                ylim(this.hAxis1D, [-1 1])
            else
            	fprintf('PupilFillGenerator updateAxes() returning since hPanel, hAxis2D or hAxis1D not handle');                
            end
            
        end
        
        % Generate a suggested name for save structure
        % @return {char 1xm}
        
        function cName = getSuggestedFileName(this)
            
            
            switch this.uipType.getSelectedValue()
                case this.cMULTIPOLE
                    switch this.uipMultiTimeType.getSelectedIndex()
                        case uint8(1)
                            % Period
                            cName = sprintf('%1.0fPole_off%1.0f_rot%1.0f_min%1.0f_max%1.0f_num%1.0f_dwell%1.0f_xoff%1.0f_yoff%1.0f_per%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uiEditMultiPoleNum.get(), ...
                                this.uiEditMultiOffset.get()*100, ...
                                this.uiEditMultiRot.get(), ...
                                this.uiEditMultiSigMin.get()*100, ...
                                this.uiEditMultiSigMax.get()*100, ...
                                this.uiEditMultiCirclesPerPole.get(), ...
                                this.uiEditMultiDwell.get(), ...
                                this.uiEditMultiXOffset.get()*100, ...
                                this.uiEditMultiYOffset.get()*100, ...
                                this.uiEditMultiPeriod.get(), ...
                                this.uiEditFilterHz.get(), ...
                                this.uiEditTimeStep.get() ...
                            );
                        case uint8(2)
                            % Freq
                            cName = sprintf('%1.0fPole_off%1.0f_rot%1.0f_min%1.0f_max%1.0f_num%1.0f_dwell%1.0f_xoff%1.0f_yoff%1.0f_hz%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uiEditMultiPoleNum.get(), ...
                                this.uiEditMultiOffset.get()*100, ...
                                this.uiEditMultiRot.get(), ...
                                this.uiEditMultiSigMin.get()*100, ...
                                this.uiEditMultiSigMax.get()*100, ...
                                this.uiEditMultiCirclesPerPole.get(), ...
                                this.uiEditMultiDwell.get(), ...
                                this.uiEditMultiXOffset.get()*100, ...
                                this.uiEditMultiYOffset.get()*100, ...
                                this.uiEditMultiHz.get(), ...
                                this.uiEditFilterHz.get(), ...
                                this.uiEditTimeStep.get() ...
                            ); 
                    end
                    
                case this.cDC
                    
                    cName = sprintf('DC_x%1.0f_y%1.0f_dt%1.0f', ...
                        this.uiEditDCx.get()*100, ...
                        this.uiEditDCy.get()*100, ...
                        this.uiEditTimeStep.get() ...
                    );
                
                case this.cRASTOR
                    
                    cName = sprintf('Rastor_%s_ramp%1.0f_dt%1.0f', ...
                        this.uiEditRastorData.get(), ...
                        this.uiEditRastorTransitTime.get(), ...
                        this.uiEditTimeStep.get() ...
                    );
                
                case this.cSAW
                   
                    switch this.uipSawTimeType.getSelectedIndex()
                        case uint8(1)
                            % Period
                            cName = sprintf('Saw_sigx%1.0f_phasex%1.0f_offx%1.0f_sigy%1.0f_phasey%1.0f_offy%1.0f_scale%1.0f_per%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uiEditSawSigX.get()*100, ...
                                this.uiEditSawPhaseX.get(), ...
                                this.uiEditSawOffsetX.get()*100, ...
                                this.uiEditSawSigY.get()*100, ...
                                this.uiEditSawPhaseY.get(), ...
                                this.uiEditSawOffsetY.get()*100, ...
                                1, ...
                                this.uiEditSawPeriod.get(), ...
                                this.uiEditFilterHz.get(), ...
                                this.uiEditTimeStep.get() ...
                            );                           
                    
                        
                        case uint8(2)
                            % Period
                            cName = sprintf('Saw_sigx%1.0f_phasex%1.0f_offx%1.0f_sigy%1.0f_phasey%1.0f_offy%1.0f_scale%1.0f_hz%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uiEditSawSigX.get()*100, ...
                                this.uiEditSawPhaseX.get(), ...
                                this.uiEditSawOffsetX.get()*100, ...
                                this.uiEditSawSigY.get()*100, ...
                                this.uiEditSawPhaseY.get(), ...
                                this.uiEditSawOffsetY.get()*100, ...
                                1, ...
                                this.uiEditSawHz.get(), ...
                                this.uiEditFilterHz.get(), ...
                                this.uiEditTimeStep.get() ...
                            );   
                    end
                    
                case this.cSERPENTINE
                    
                    cName = sprintf('Serpentine_sigx%1.0f_numx%1.0f_offx%1.0f_sigy%1.0f_numy%1.0f_offy%1.0f_scale%1.0f_per%1.0f_filthz%1.0f_dt%1.0f',...
                        this.uiEditSerpSigX.get()*100, ...
                        this.uiEditSerpNumX.get(), ...
                        this.uiEditSerpOffsetX.get()*100, ...
                        this.uiEditSerpSigY.get()*100, ...
                        this.uiEditSerpNumY.get(), ...
                        this.uiEditSerpOffsetY.get()*100, ...
                        1, ...
                        this.uiEditSerpPeriod.get(), ...
                        this.uiEditFilterHz.get(), ...
                        this.uiEditTimeStep.get() ...
                    );
                case this.cQUASAR
                    
                    cName = [...
                        'Quasar_', ...
                        sprintf('rIn%1.0f_', this.uiEditQuasarRadiusInner.get() * 100)...
                        sprintf('rOut%1.0f_', this.uiEditQuasarRadiusOuter.get() * 100), ...
                        sprintf('numPoles%1.0f_', this.uiEditQuasarNumPoles.get()), ...
                        sprintf('numArcs%1.0f_', this.uiEditQuasarNumArcs.get()), ...
                        sprintf('theta%1.1f_', this.uiEditQuasarTheta.get()), ...
                        sprintf('rot%1.1f_', this.uiEditQuasarRot.get()), ...
                        sprintf('offX%1.0f_', this.uiEditQuasarOffsetX.get() * 100), ...
                        sprintf('offY%1.0f_', this.uiEditQuasarOffsetY.get() * 100), ...
                        sprintf('period%1.0f_', this.uiEditQuasarPeriod.get()), ...
                        sprintf('filthz%1.0f_', this.uiEditFilterHz.get()), ...
                        sprintf('dt%1.0f', this.uiEditTimeStep.get()) ...
                    ];
                     
            end
            
        end
        
        function onSave(this, src, evt)
                        
            cName = this.getSuggestedFileName();
                        
            % NEW 2017.02.02
            % Allow the user to change the filename, if desired but do not
            % allow them to select a different directory.
            
            cePrompt = {'Save As:'};
            cTitle = '';
            dLines = [1 130];
            ceDefaultAns = {cName};
            ceAnswer = inputdlg(...
                cePrompt,...
                cTitle,...
                dLines,...
                ceDefaultAns ...
            );
            
            if isempty(ceAnswer)
                return
            end
            
            this.savePupilFill([ceAnswer{1}, '.mat']);
                       
        end
        
        % @param {char 1xm} cFileName name of file with '.mat' extension
        function savePupilFill(this, cFileName)
                                                
            s = this.savePanelWaveformState();
            
            % 2017.11.29
            % Could append x, y, t to the structure if I wand and then
            % the value is always available later on
            
            save(fullfile(this.uiListDirSaved.getDir(), cFileName), 's');
            
            % Update the mic.ui.common.ListDir
            this.uiListDirSaved.refresh();
                       
        end
        
        
        
        function buildPanelWaveform(this)
                        
            if ~ishandle(this.hPanel)
                return;
            end

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 55;

            % Panel
            this.hPanelWaveform = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Waveform Properties',... 
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 10 210 630], this.hPanel) ...
            );
            drawnow;


            % Popup (to select type)
            this.uipType.build(this.hPanelWaveform, dLeftCol1, dTop, 190, this.dHeightEdit);

            % Build the sub-panel based on popup type 
            switch this.uipType.getSelectedValue()
                case this.cMULTIPOLE
                    this.buildPanelWaveformMulti();
                case this.cDC
                    this.buildPanelWaveformDC();
                case this.cRASTOR
                    this.buildPanelWaveformRastor();
                case this.cSAW
                    this.buildPanelWaveformSaw();
                case this.cSERPENTINE
                    this.buildPanelWaveformSerp();
                case this.cQUASAR
                    this.buildPanelWaveformQuasar();
            end


            % Build sub-panel for parameters that apply to all waveform
            this.buildPanelWaveformGeneral();


            % Preview and save buttons
            dTop = 560;
            this.uiButtonPreview.build(this.hPanelWaveform, dLeftCol1, dTop, 190, this.dHeightEdit);
            dTop = dTop + 30;

            this.uiButtonSave.build(this.hPanelWaveform, dLeftCol1, dTop, 190, this.dHeightEdit);
            dTop = dTop + dSep;
                
            
        end
        
        function buildPanelWaveformGeneral(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 55;

            % Panel

            this.hPanelWaveformGeneral = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'General',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 420 190 130], this.hPanelWaveform) ...
            );
            drawnow;

            % Build filter Hz, Volts scale and time step

            this.uiEditFilterHz.build(this.hPanelWaveformGeneral, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);            
            dTop = dTop + dSep;

            this.uiEditTimeStep.build(this.hPanelWaveformGeneral, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditConvKernelSig.build(this.hPanelWaveformGeneral, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);

            dTop = dTop + dSep; 
                            
        end
        
        
        function buildPanelWaveformMulti(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end
            
            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 40;

            % Panel
            this.hPanelWaveformMulti = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'Multipole configuration',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 350], this.hPanelWaveform) ...
            );
            drawnow;

            this.uiEditMultiPoleNum.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiTransitTime.build(this.hPanelWaveformMulti, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditMultiSigMin.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiSigMax.build(this.hPanelWaveformMulti, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);
            dTop = dTop + dSep;

            this.uiEditMultiCirclesPerPole.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiDwell.build(this.hPanelWaveformMulti, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);
            dTop = dTop + dSep;

            this.uiEditMultiOffset.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiRot.build(this.hPanelWaveformMulti, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);
            dTop = dTop + dSep;

            this.uiEditMultiXOffset.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiYOffset.build(this.hPanelWaveformMulti, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);
            dTop = dTop + dSep;

            % Popup (to select type)
            this.uipMultiTimeType.build(this.hPanelWaveformMulti, dLeftCol1, dTop, 170, this.dHeightEdit);
            dTop = dTop + 45;

            this.uiEditMultiPeriod.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditMultiHz.build(this.hPanelWaveformMulti, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);                

            % Call handler for multitimetype to make active type visible
            this.onMultiTimeTypeChange();
            dTop = dTop + 45;

            this.uitMultiFreqRange.build(this.hPanelWaveformMulti, dLeftCol1, dTop, 170, 30);

            drawnow;
                
            
        end
        
        function buildPanelWaveformDC(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 55;

            % Panel

            this.hPanelWaveformDC = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'DC configuration',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 80], this.hPanelWaveform) ...
            );
            drawnow;


            this.uiEditDCx.build(this.hPanelWaveformDC, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);            
            this.uiEditDCy.build(this.hPanelWaveformDC, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);

            drawnow;

        end
        
        function buildPanelWaveformRastor(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end
            

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 55;

            % Panel
            this.hPanelWaveformRastor = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'Rastor configuration',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 130], this.hPanelWaveform) ...
            );
            drawnow;


            this.uiEditRastorData.build(this.hPanelWaveformRastor, dLeftCol1, dTop, 170, this.dHeightEdit); 
            dTop = dTop + dSep;     

            this.uiEditRastorTransitTime.build(this.hPanelWaveformRastor, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);

            drawnow;
                        
        end
        
        function buildPanelWaveformSaw(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 55;

            this.hPanelWaveformSaw = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'Triangle configuration',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 300], this.hPanelWaveform) ...
            );
            drawnow;

            this.uiEditSawSigX.build(this.hPanelWaveformSaw, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSawSigY.build(this.hPanelWaveformSaw, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditSawPhaseX.build(this.hPanelWaveformSaw, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSawPhaseY.build(this.hPanelWaveformSaw, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditSawOffsetX.build(this.hPanelWaveformSaw, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSawOffsetY.build(this.hPanelWaveformSaw, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uipSawTimeType.build(this.hPanelWaveformSaw, dLeftCol1, dTop, 170, this.dHeightEdit);

            dTop = dTop + 45;

            this.uiEditSawPeriod.build(this.hPanelWaveformSaw, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSawHz.build(this.hPanelWaveformSaw, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);                
            this.onSawTimeTypeChange(); % Call handler for multitimetype to make active type visible

            drawnow;
            
        end
        
        function buildPanelWaveformQuasar(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end
            
            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 40;

            this.hPanelWaveformQuasar = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'Quasar Config',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 230], this.hPanelWaveform) ...
            );
            drawnow;
            
            this.uiEditQuasarRadiusInner.build(this.hPanelWaveformQuasar, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditQuasarRadiusOuter.build(this.hPanelWaveformQuasar, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;
            
            this.uiEditQuasarNumPoles.build(this.hPanelWaveformQuasar, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);            
            this.uiEditQuasarNumArcs.build(this.hPanelWaveformQuasar, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);

            dTop = dTop + dSep;
            
            this.uiEditQuasarTheta.build(this.hPanelWaveformQuasar, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditQuasarRot.build(this.hPanelWaveformQuasar, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;
            
            this.uiEditQuasarOffsetX.build(this.hPanelWaveformQuasar, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditQuasarOffsetY.build(this.hPanelWaveformQuasar, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;
            
            this.uiEditQuasarPeriod.build(this.hPanelWaveformQuasar, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            
        end
        
        
        function buildPanelWaveformSerp(this)
            
            if ~ishandle(this.hPanelWaveform)
                return
            end

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            dTop = 20;
            dSep = 40;

            this.hPanelWaveformSerp = uipanel(...
                'Parent', this.hPanelWaveform,...
                'Units', 'pixels',...
                'Title', 'Serpentine config',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([10 65 190 190], this.hPanelWaveform) ...
            );
            drawnow;

            this.uiEditSerpSigX.build(this.hPanelWaveformSerp, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSerpSigY.build(this.hPanelWaveformSerp, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditSerpNumX.build(this.hPanelWaveformSerp, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSerpNumY.build(this.hPanelWaveformSerp, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditSerpOffsetX.build(this.hPanelWaveformSerp, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);
            this.uiEditSerpOffsetY.build(this.hPanelWaveformSerp, dLeftCol2, dTop, dEditWidth, this.dHeightEdit);            

            dTop = dTop + dSep;

            this.uiEditSerpPeriod.build(this.hPanelWaveformSerp, dLeftCol1, dTop, dEditWidth, this.dHeightEdit);

            drawnow;
            
        end
        
        function buildPanelSaved(this)
            
            if ~ishandle(this.hPanel)
                return;
            end
            
            dWidth = this.dWidthPanelSaved;

            hPanel = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Saved',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([230 320 dWidth 320], this.hPanel) ...
            );
            drawnow;
            
            dButtonWidth = 100;
            this.uiListDirSaved.build(...
                hPanel, ...
                10, ...
                20, ...
                dWidth-20, ...
                220 ...
            );
            
        end
        
        
        
        
        
        
        
        function buildPanelPlot(this)
            

            dSize = 220;
            dPad = 30;

            this.hPanelPlot = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Preview',...
                'Clipping', 'on',... 
                'BackgroundColor', [1 1 1], ...
                'BorderType', 'none', ...
                'Position', mic.Utils.lt2lb([230 10 this.dWidthPanelPlot 300], this.hPanel) ...
            );
            drawnow;            

            dTop = 30;
            this.hAxis1D = axes(...
                'Parent', this.hPanelPlot,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([dPad + 15 dTop dSize*2 - 15 dSize], this.hPanelPlot),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'HandleVisibility','on'...
                );

            this.hAxis2D = axes(...
                'Parent', this.hPanelPlot,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([2*(dPad+dSize) dTop dSize dSize], this.hPanelPlot),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
                );

            this.hAxis2DSim = axes(...
                'Parent', this.hPanelPlot,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([3*(dSize+dPad) dTop dSize dSize], this.hPanelPlot),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
                );

                % 'PlotBoxAspectRatio',[obj.xpix obj.ypix 1],...
                % 'XTick',[],...
                % 'YTick',[],...
                % 'Xlim',[obj.stagexminCAL obj.stagexmaxCAL] ...
                % 'Color',[0.3,0.3,0.3],...
                                
        end

        function updatePupilImg(this)

            % Return if the handles don't exist
            
            if  ishandle(this.hPanel) & ...
                ishandle(this.hAxis2DSim)
                % Proceed
            else
                return;
            end
                    
           
            % 2013.08.19 CNA
            % Passing in Vx and Vy now so it is easy to do with the sensor
            % data and not just the preview waveform data
           
            % Create empty pupil fill matrices

            int = zeros(this.dPreviewPixels,this.dPreviewPixels);

            % Map each (vx,vy) pair to its corresponding pixel in the pupil
            % fill matrices.  For vy, need to flip its sign before
            % computing the pixel because of the way matlab does y
            % coordinates in an image plot

            dVoltsAtEdge = this.dPupilScale*1;

            
            % dVxPixel {double 1 x length(dVx)}
            % dVyPixel {double 1 x length(dVy)}
            % 
            dVxPixel = ceil(this.dVx/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);
            dVyPixel = ceil(-this.dVy/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);                    
            

            % If any of the pixels lie outside the matrix, discard them

            dIndex = find(  dVxPixel <= this.dPupilPixels & ...
                            dVxPixel > 0 & ...
                            dVyPixel <= this.dPupilPixels & ...
                            dVyPixel > 0 ...
                            );

            dVxPixel = dVxPixel(dIndex);
            dVyPixel = dVyPixel(dIndex);

            % Add a "1" at each pixel where (vx,vy) pairs reside.  We may end up adding
            % "1" to a given pixel a few times - especially if the dwell is set to more
            % than 1.

            for n = 1:length(dVxPixel)
                int(dVyPixel(n), dVxPixel(n)) = int(dVyPixel(n), dVxPixel(n)) + 1;
            end

%             for n = 1:length(x_gc)
%                 int_gc(y_gc(n),x_gc(n)) = int_gc(y_gc(n),x_gc(n)) + 1;
%             end

            % Get the convolution kernel and convolve the pseudo-intensity
            % map with kernel and normalize


            [dX, dY, dKernelInt] = this.getKernel();            

            int = conv2(int,dKernelInt.^2,'same');
            int = int./max(max(int));
            % int = imrotate(int, 90);


            % Fill simulated with gain plot.  Old way to activate the axes we want:
            % axes(handles.pupil_axes), however this way sucks because it actually
            % creates a new

            hParent = this.hAxis2DSim;
                
            imagesc(int, 'Parent', hParent)
            axis(hParent, 'image')
            colormap(hParent, 'jet');
            
            if this.lSerpentineDebug
                
                % Propagate 4 m with an angle of 6 mrad gives 24 mm of
                % displacement at the wafer at +10 volts (sig = 1) and - 24 mm at -
                % 10 volts.  
                
                dMmPerSig = 24;
                dMmPerVolts = 24/10;
                
                
                % Kernel
                imagesc(dX(:, 1)*dMmPerSig, dY(1, :)*dMmPerSig, dKernelInt, ...
                    'Parent', this.hSerpentineKernelAxes ...
                )
                axis(this.hSerpentineKernelAxes, 'image')
                colormap(this.hSerpentineKernelAxes, 'jet');
                xlabel(this.hSerpentineKernelAxes, 'x (mm)');
                ylabel(this.hSerpentineKernelAxes, 'y (mm)');
                
                % Waveform
                plot(this.dVx*dMmPerVolts, this.dVy*dMmPerVolts, 'b', ...
                    'Parent', this.hSerpentineWaveformAxes ...
                );
                axis(this.hSerpentineWaveformAxes, 'image')
                xlim(this.hSerpentineWaveformAxes, [-1 1]*dMmPerVolts)
                ylim(this.hSerpentineWaveformAxes, [-1 1]*dMmPerVolts)
                xlabel(this.hSerpentineWaveformAxes, 'x (mm)');
                ylabel(this.hSerpentineWaveformAxes, 'y (mm)');
                
                
                % Convolution
                imagesc(dX(:, 1)*dMmPerSig, dY(1, :)*dMmPerSig, int, ...
                    'Parent', this.hSerpentineConvAxes ...
                )
                axis(this.hSerpentineConvAxes, 'image')
                colormap(this.hSerpentineConvAxes, 'jet');
                xlabel(this.hSerpentineConvAxes, 'x (mm)');
                ylabel(this.hSerpentineConvAxes, 'y (mm)');
                
                % Apertured convolution
                
                % Box half width and half height in mm
                dBoxXLim = 5;
                dBoxYLim = 5;
                
                % Box sigma
                dSigXLim = dBoxXLim/dMmPerSig;
                dSigYLim = dBoxYLim/dMmPerSig;
               
                dIndex = abs(dX) > dSigXLim | abs(dY) > dSigYLim;
                
                intCrop = int;
                dXCrop = dX;
                dYCrop = dY;
                
                intCrop(dIndex) = 0;
                intCropCalc = intCrop;
                intCropCalc(dIndex) = [];
                
                
                
                imagesc(dXCrop(:, 1)*dMmPerSig, dYCrop(1, :)*dMmPerSig, intCrop, ...
                    'Parent', this.hSerpentineConvOutputAxes ...
                );
                %{
                imagesc(intCrop, ...
                    'Parent', this.hSerpentineConvOutputAxes ...
                )
                %}
                axis(this.hSerpentineConvOutputAxes, 'image')
                colormap(this.hSerpentineConvOutputAxes, 'jet');
                xlabel(this.hSerpentineConvOutputAxes, 'x (mm)');
                ylabel(this.hSerpentineConvOutputAxes, 'y (mm)');
                xlim(this.hSerpentineConvOutputAxes, [-dSigXLim dSigXLim]*dMmPerSig);
                ylim(this.hSerpentineConvOutputAxes, [-dSigYLim dSigYLim]*dMmPerSig);
                
                title(this.hSerpentineKernelAxes, 'Unscanned beam');
                title(this.hSerpentineWaveformAxes, 'Scan path');
                title(this.hSerpentineConvAxes, 'Scanned beam');
                title(this.hSerpentineConvOutputAxes, ...
                    sprintf(...
                        'Central %1.0f mm x %1.0f mm RMS = %1.1f%%, PV = %1.1f%%', ...
                        dBoxXLim*2, ...
                        dBoxYLim*2, ...
                        std(intCropCalc)*100, ...
                        100*(max(intCropCalc) - min(intCropCalc)) ...
                    ) ...
                );
                
                
                % Draw border box
                
                dXBox = [-dSigXLim -dSigXLim dSigXLim dSigXLim -dSigXLim];
                dYBox = [-dSigYLim  dSigYLim dSigYLim -dSigYLim -dSigYLim];
                
                % When x/y are mm
                dXBox = dXBox*dMmPerSig;
                dYBox = dYBox*dMmPerSig;
                
                %{
                % When x/y is pixels
                dXBox = dXBox*this.dPupilPixels/this.dPupilScale/2 + this.dPupilPixels/2;
                dYBox = dYBox*this.dPupilPixels/this.dPupilScale/2 + this.dPupilPixels/2;
                %}
                                
                line( ...
                    dXBox, dYBox, ...
                    'color', [1 1 1], ...
                    'LineWidth', 1, ...
                    'Parent', this.hSerpentineConvAxes ...
                );
            
                % 2016.03.02 plot the derivative of the voltage w.r.t to
                % time and multiply by the capicatance to get the current
                
                ddVxdT = derivative(this.dVx, this.uiEditTimeStep.get()*1e-6);
                ddVydT = derivative(this.dVy, this.uiEditTimeStep.get()*1e-6);
                
                dC = 2e-6; % advertised
                dC_scale_factor = 300/113;
                
                dIx = ddVxdT*dC*dC_scale_factor;
                dIy = ddVydT*dC*dC_scale_factor;
                
                % hold(this.hSerpentineCurrentAxes);
                plot(this.dTime*1000, dIx*1000, 'r', ...
                    'Parent', this.hSerpentineCurrentAxes ...
                );
                plot(this.dTime*1000, dIy*1000, 'b', ...
                    'Parent', this.hSerpentineCurrentAxes ...
                );
                xlabel(this.hSerpentineCurrentAxes, 'Time (ms)');
                ylabel(this.hSerpentineCurrentAxes, 'Current (mA)');
                title(this.hSerpentineCurrentAxes, 'Scanner current (300 mA max)');
                xlim(this.hSerpentineCurrentAxes, [0 max(this.dTime)*1000]);
            
            end
            
        
               

            % Create plotting data for circles at sigma = 0.3 - 1.0

            dSig = [0.3:0.1:1.0];
            dPhase = linspace(0, 2*pi, this.dPupilPixels);

            for (k = 1:length(dSig))

                % set(this.hPanel, 'CurrentAxes', this.hAxis2DSim)
                x = dSig(k)*this.dPupilPixels/this.dPupilScale/2*cos(dPhase) + this.dPupilPixels/2;
                y = dSig(k)*this.dPupilPixels/this.dPupilScale/2*sin(dPhase) + this.dPupilPixels/2;
                line( ...
                    x, y, ...
                    'color', [0.3 0.3 0.3], ... % [0.3 0.1 0.4], ... % [1 1 0] == yellow
                    'LineWidth', 1, ...
                    'Parent', hParent ...
                    );

            end

        end

        
        function [X,Y] = getXY(this, Nx, Ny, Lx, Ly)

            % Sample spacing

            dx = Lx/Nx;
            dy = Ly/Ny;


            % Sampled simulation points 1D 

            x = -Lx/2:dx:Lx/2 - dx;
            y = -Ly/2:dy:Ly/2 - dy;
            % u = -1/2/dx: 1/Nx/dx: 1/2/dx - 1/Nx/dx;
            % v = -1/2/dy: 1/Ny/dy: 1/2/dy - 1/Ny/dy;

            [Y,X] = meshgrid(y,x);
            % [V,U] = meshgrid(v,u);
            
        end
        
        
        function [out] = gauss(this, x, sigx, y, sigy)

            if nargin == 5
                out = exp(-((x/sigx).^2/2+(y/sigy).^2/2)); 
            elseif nargin == 4;
                disp('Must input x,sigx,y,sigy in ''gauss'' function')
            elseif nargin == 3;
                out = exp(-x.^2/2/sigx^2);
            elseif nargin == 12;
                out = exp(-x.^2/2);
            end
            
        end
        
        
        function onListChange(this, src, evt)
            
            this.msg('onListChange()');
            
            % Load the .mat file
            ceSelected = this.uiListDirSaved.get();
            
            if ~isempty(ceSelected)
                
                % ceSelected is a cell of selected options - use the first
                % one.  Populates a structure named s in the local
                % workspace of this method
                
                cFile = fullfile( ...
                    this.uiListDirSaved.getDir(), ...
                    ceSelected{1} ...
                );
            
                
                if exist(cFile, 'file') ~= 0
                
                    load(cFile); % populates structure s in local workspace

                    this.loadPanelWaveformState(s);
                    
                    % When dVx, dVy, etc. are private
                    this.preview();  
                    
                    % When dVx, dVy, etc. are public
                    
                else
                    
                    % warning message box
                    
                    h = msgbox( ...
                        'This pupil file file cannot be found.  Click OK below to continue.', ...
                        'File does not exist', ...
                        'warn', ...
                        'modal' ...
                        );
                    
                    % wait for them to close the message
                    uiwait(h);
                    
                    
                end
                
                
            else
                
                % ceSelected is an empty [1x0] cell.  do nothing
                
            end
            
 
        end
        
        function buildCameraPanel(this)
            
            if ishandle(this.hPanel)

                % Panel
                this.hCameraPanel = uipanel(...
                    'Parent', this.hPanel,...
                    'Units', 'pixels',...
                    'Title', 'Camera overlay with sigma annular lines',...
                    'Clipping', 'on',...
                    'Position', mic.Utils.lt2lb([720 this.dYOffset 400 350], this.hPanel) ...
                );
                drawnow;
            end
            
        end        
        
        
        
        
        % @return {double m x n} return a matrix that represents the
        % intensity distribution of the scan kernel (beam intensity). 
        
        function [dX, dY, dKernelInt] = getKernel(this)
            
            dKernelSig = 0.02; % Using uiEdit now.
            
            dKernelSigPixels = this.uiEditConvKernelSig.get()*this.dPupilPixels/this.dPupilScale/2;
            dKernelPixels = floor(dKernelSigPixels*2*4); % the extra factor of 2 is for oversize padding
            [dX, dY] = this.getXY(dKernelPixels, dKernelPixels, dKernelPixels, dKernelPixels);
            dKernelInt = this.gauss(dX, dKernelSigPixels, dY, dKernelSigPixels);
                        
            [dX, dY] = this.getXY(this.dPreviewPixels, this.dPreviewPixels, 2*this.dPreviewScale, 2*this.dPreviewScale);
            dKernelInt = this.gauss(dX, this.uiEditConvKernelSig.get(), dY, this.uiEditConvKernelSig.get());
            
            
            if this.lSerpentineDebug
                            

                % Update.  Build an aberrated, lumpy footprint for developing
                % serpentine patterns

                dKernelInt = zeros(size(dY));
                dTrials = 12;
                dSpread = 0.15; % Use spread = 0.15 with sigma = 0.1 (in the GUI) to get lumpy sigma = 0.2 spots
                dMag = abs(randn(1, dTrials));
                dX0 = randn(1, dTrials)*dSpread*this.dPreviewScale;
                dY0 = randn(1, dTrials)*dSpread*this.dPreviewScale;

                for n = 1:dTrials
                    dKernelInt = dKernelInt + dMag(n)*this.gauss(...
                        dX - dX0(n), ...
                        this.uiEditConvKernelSig.get(), ...
                        dY - dY0(n), ...
                        this.uiEditConvKernelSig.get());
                end


                % Compute center of mass and circshift the matrix so the center
                % of mass is in the center

                dArea = sum(sum(dKernelInt));
                dMeanX = sum(sum(dKernelInt.*dX))/dArea*this.dPreviewPixels/2;
                dMeanY = sum(sum(dKernelInt.*dY))/dArea*this.dPreviewPixels/2;

                dKernelInt = circshift(dKernelInt, [-round(dMeanX), -round(dMeanY)]);
                               
           
            end
            
        end
         
    end

end
        
        
        