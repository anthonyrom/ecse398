classdef swagFX < audioPlugin
    % Spectral Wavetable Audio/Guitar FX Unit
    properties
        % Public, tunable properties
        swagG = 1.2 % Contour constant
        swagA = 1.1; % z-plane spiral starting point 
        swagS = OutputSelect.cplxMag; % selects output component
        swagMix = 0.0; % wet/dry effect mix
    end
    properties (Constant)
        % Define plugin interface
        PluginInterface = audioPluginInterface(...
            'PluginName', 'SWAG FX Processor', ...,
            'VendorName', 'ECSE 398', ...
            audioPluginParameter('swagMix', ...
                'DisplayName', 'SWAG wet-dry mix', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('swagA', ...
                'DisplayName', 'Spiral origin point', ...
                'Mapping', {'lin', 0.5, 2}), ...
            audioPluginParameter('swagG', ...
                'DisplayName', 'Spiral contour constant', ...
                'Mapping', {'lin', 0.5, 1.5}), ...
            audioPluginParameter('swagS', ...
                'DisplayName', 'Component select', ...
                'Mapping', {'enum', 'cplx mag', 'real', 'imag'}));
    end
    methods
        function out = process(plugin, in)
            % Instructions to process input audio signal

            % Write settings
            swagM = length(in); % Frame size (# of samples)
            swagW = nthroot(plugin.swagG, swagM)*exp((1i*2*pi)/swagM); % Spiral contour
            swagAval = plugin.swagA;
            swagSval = plugin.swagS;
            mixVal = plugin.swagMix;
            
            % Apply waveshaping
            trans = FCZT(in, swagM, swagW, swagAval);
            preOut1 = IFCZT(trans, swagM, swagW, swagAval);
            
            % Select output component
            switch(swagSval)
                case OutputSelect.cplxMag
                    preOut2 = abs(preOut1);
                case OutputSelect.realPart
                    preOut2 = real(preOut1);
                case OutputSelect.imagPart
                    preOut2 = imag(preOut1);
                otherwise
                    % This shouldn't happen
                    preOut2 = in;
            end
            
            % Apply wet/dry mixing
            out = ((1-mixVal).*in) + (mixVal.*sum(preOut2,3));
        end
        function reset(plugin)
            % Instructions to reset plugin.
            plugin.swagMix = 0.0;
        end
    end
end