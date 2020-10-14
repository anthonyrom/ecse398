classdef swagFX < audioPlugin
    % Spectral Wavetable Audio/Guitar FX Unit
    properties
        % Initialize properties for end-user interaction
        
        % Reverb Parameters
        ReverbPreDelay = 0;
        ReverbHighCutFreq = 20000;
        ReverbDiffusion = 0.5;
        ReverbDecayFactor = 0.5;
        ReverbHighFreqDamping = 0.0005;
        ReverbMix = 0.3;
    end
    properties (Access = private)
        % Initialize properties NOT for end-user interaction
        Reverb
    end
    properties (Constant)
        % Instructions to build audio plugin interface.
        % End-user uses interface to adjust tunable parameters.
        
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('ReverbPreDelay', ...
                'DisplayName', 'Pre-delay for reverberation', ...
                'Label', 's', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('ReverbHighCutFreq', ...
                'DisplayName', 'Lowpass filter cutoff', ...
                'Label', 'Hz', ...
                'Mapping', {'lin', 0, 20000}), ...
            audioPluginParameter('ReverbDiffusion', ...
                'DisplayName', 'Density of reverb tail', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('ReverbDecayFactor', ...
                'DisplayName', 'Decay factor of reverb tail', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('ReverbHighFreqDamping', ...
                'DisplayName', 'High-frequency damping', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('ReverbMix', ...
                'DisplayName', 'Wet-dry mix', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}));
    end
    methods
        function plugin = swagFX
            plugin.Reverb = reverberator();
        end
        function out = process(plugin, in)
            % Instructions to process input audio signal
            frameSize = size(in, 1);
            
            % Write Reverb settings
            plugin.Reverb.PreDelay = plugin.ReverbPreDelay;
            plugin.Reverb.HighCutFrequency = plugin.ReverbHighCutFreq;
            plugin.Reverb.Diffusion = plugin.ReverbDiffusion;
            plugin.Reverb.DecayFactor = plugin.ReverbDecayFactor;
            plugin.Reverb.HighFrequencyDamping = plugin.ReverbHighFreqDamping;
            plugin.Reverb.WetDryMix = plugin.ReverbMix;
            
            % Apply changes to audio stream
            out = plugin.Reverb(in);
        end
        function reset(plugin)
            % Instructions to reset plugin.
            plugin.Reverb.SampleRate = getSampleRate(plugin);
        end
    end
end