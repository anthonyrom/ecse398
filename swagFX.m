classdef swagFX < audioPlugin
    % Spectral Wavetable Audio/Guitar FX Unit
    properties
        % Public, tunable properties
        
        % Reverb Parameters
        rPreDelay = 0; % sec
        rHighCutFreq = 20000; % Hz
        rDiffusion = 0.5;
        rDecayFactor = 0.5;
        rHighFreqDamping = 0.0005;
        rMix = 0.3;
        
        % Flanger Parameters
        fDelay = 0.001; % seconds
        fDepth = 30;
        fRate = 0.25; % Hz
        fFeedback = 0.4;
        fMix = 0.3;
    end
    properties (Access = private, Hidden)
        % Pre-computed constants (not tunable) 
        
        % Reverb
        Reverb;
        
        % Flanger
        pFractionalDelay;
        pSine;
        pSR;
    end
    properties (Constant)
        % Define plugin interface
        
        PluginInterface = audioPluginInterface(...
            'PluginName', 'SWAG FX Processor', ...,
            'VendorName', 'ECSE 398', ...
            audioPluginParameter('rPreDelay', ...
                'DisplayName', 'Reverb pre-delay', ...
                'Label', 's', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('rHighCutFreq', ...
                'DisplayName', 'Reverb lowpass filter cutoff', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 20, 20000}), ...
            audioPluginParameter('rDiffusion', ...
                'DisplayName', 'Density of reverb tail', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('rDecayFactor', ...
                'DisplayName', 'Decay factor of reverb tail', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('rHighFreqDamping', ...
                'DisplayName', 'Reverb high-frequency damping', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('rMix', ...
                'DisplayName', 'Reverb wet-dry mix', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('fDelay', ...
                'DisplayName', 'Flanger base delay', ...
                'Label', 'sec', ...
                'Mapping', {'lin', 0, 0.1}), ...
            audioPluginParameter('fDepth', ...
                'DisplayName', 'Flanger modulation depth', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 50}), ...
            audioPluginParameter('fRate', ...
                'DisplayName', 'Flanger modulation rate', ...
                'Label', 'Hz', ...
                'Mapping', {'lin', 0, 0.5}), ...
            audioPluginParameter('fFeedback', ...
                'DisplayName', 'Flanger feedback', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('fMix', ...
                'DisplayName', 'Flanger wet-dry mix', ...
                'Label', '', ...
                'Mapping', {'lin', 0, 1}));
    end
    methods
        function plugin = swagFX
            plugin.Reverb = reverberator();
            fs = getSampleRate(plugin);
            
            % create modulators
            plugin.pSine = audioOscillator('Frequency', 0.25, ...
                'Amplitude', 30, 'SampleRate', fs);
            
            % create fractional delay
            plugin.pFractionalDelay = audioexample.DelayFilter(...,
                'FeedbackLevel', 0.4, ...
                'SampleRate', fs);
            % Sample rate
            plugin.pSR = fs;
        end
        function set.fDepth(plugin, val)
            plugin.pSine.Amplitude = val;
        end
        function val = get.fDepth(plugin)
            val = plugin.pSine.Amplitude;
        end
        function set.fRate(plugin, val)
            plugin.pSine.Frequency = val;
        end
        function val = get.fRate(plugin)
            val = plugin.pSine.Frequency;
        end
        function set.fFeedback(plugin, val)
            plugin.pFractionalDelay.FeedbackLevel = val;
        end
        function val = get.fFeedback(plugin)
            val = plugin.pFractionalDelay.FeedbackLevel;
        end
        
        function out = process(plugin, in)
            % Instructions to process input audio signal
            frameSize = size(in, 1);
            
            flangerSR = plugin.pSR;
            flangerOsc = plugin.pSine;
            flangerDelay = plugin.pFractionalDelay;
            
            % Reverb settings
            plugin.Reverb.PreDelay = plugin.rPreDelay;
            plugin.Reverb.HighCutFrequency = plugin.rHighCutFreq;
            plugin.Reverb.Diffusion = plugin.rDiffusion;
            plugin.Reverb.DecayFactor = plugin.rDecayFactor;
            plugin.Reverb.HighFrequencyDamping = plugin.rHighFreqDamping;
            plugin.Reverb.WetDryMix = plugin.rMix;
            
            % Flanger
            delaySamples = plugin.fDelay*flangerSR;
            flangerOsc.SamplesPerFrame = frameSize;
            delayVec = delaySamples+flangerOsc();
            delayedIn = flangerDelay(delayVec, in);
            mix = plugin.fMix;
            y = (1-mix)*in + mix.*delayedIn;
            
            % Apply Reverb and output
            out = plugin.Reverb(y);
        end
        function reset(plugin)
            % Instructions to reset plugin.
            
            % Reset sample rate
            fs = getSampleRate(plugin);
            plugin.Reverb.SampleRate = fs;
            plugin.pSR = fs;
            
            % Reset flanger
            plugin.pSine.SampleRate = fs;
            reset(plugin.pSine)
            plugin.pFractionalDelay.SampleRate = fs;
            reset(plugin.pFractionalDelay)

        end
    end
end