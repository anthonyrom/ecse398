classdef ecse398 < audioPlugin
    properties
        % For tunable properties
        
        % SWAG properties
        swagA = 1; % z-plane spiral starting point
        swagG = 1 % spiral contour constant
        swagMix = 0;
        
        % Upsampling properties
        interpScale = 2;
    end
    properties (Access = private)
        % For non-user facing properties
    end
    properties (Constant)
        % For user interface
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            'PluginName','ECSE 398',...
            'VendorName','ECSE 398',...
            'VendorVersion','1.0.0',...
            'UniqueId','ipsg',...
            audioPluginParameter('swagMix','DisplayName','Wet/Dry Mix',...
            'Label','','Mapping',{'lin' 0 1}, ...
            'Style','rotaryknob','Layout',[2,1;6,1],...
            'DisplayNameLocation','Above'), ...
            audioPluginParameter('swagA','DisplayName','Modifier 1',...
            'Label','','Mapping',{'lin', 0.99 1.01},...
            'Style','rotaryknob','Layout',[2,2;6,2],...
            'DisplayNameLocation','Above'),...
            audioPluginParameter('swagG','DisplayName','Modifier 2',...
            'Label','','Mapping',{'lin', 1, 1.03},...
            'Style','rotaryknob','Layout',[2,3;6,3],...
            'DisplayNameLocation','Above'),...
            audioPluginParameter('interpScale','DisplayName','Upsample Factor',...
            'Label','','Mapping',{'int' 1, 6},...
            'Style','vslider','Layout',[2,4;6,4],...
            'DisplayNameLocation','Above'),...
            audioPluginGridLayout(...
            'RowHeight', [20, 40, 40, 40, 40, 20],...
            'ColumnWidth', [100, 100, 100, 100, 100]),...
            'BackgroundImage', audiopluginexample.private.mwatlogo);
    end
    methods
        function out = process(plugin, in)
            % input size: frameLength x 2 matrix of doubles
            % Load settings
            frameLength = length(in);
            swagMix_ = plugin.swagMix;
            swagW_ = nthroot(plugin.swagG, frameLength)*exp((1i*2*pi)/frameLength);
            swagA_ = plugin.swagA;
            interpScale_ = plugin.interpScale;
            
            % Convert stereo signal to mono
            logVec = ~sum(in == 0, 2); % rows without zeros
            monoSig = sum(in, 2)/2; % sum channels
            monoSig(logVec) = monoSig(logVec)/2; % get mean for nonzero rows
            
            % Upsample mono signal 
            inTerp = interp(monoSig, interpScale_);
           
            % Apply S.W.A.G.
            transMono = FCZT(inTerp, frameLength, swagW_, swagA_);
            invMono = IFCZT(transMono, frameLength, swagW_, swagA_).';

            %deTerp = downsample(invMono, interpScale_);
            swagOut = abs(horzcat(invMono, invMono));
            
            % Downsample
            %deTerp = downsample(swagOut, interpScale_);
            
            % Write output
            out = ((1-swagMix_).*in) + (swagMix_.*sum(swagOut, 3));
            %out = ((1-revMix).*swagOut) + (revMix.*sum(revOut, 3));
        end
        function reset(plugin)
            % Reset instructions, between plugin uses/ sample rate changes
        end
    end
end