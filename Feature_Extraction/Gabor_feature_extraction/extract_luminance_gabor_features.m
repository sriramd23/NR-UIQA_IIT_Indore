function FGabor = extract_luminance_gabor_features(imgRGB)
% Output: 1 × 12 luminance Gabor energy features

% --- RGB → OCS ---
[~, ~, O3] = rgb2ocs(imgRGB);

% --- Paper-locked parameters ---
nscale        = 2;
norient       = 6;
minWaveLength = 3;
mult          = 1.7;
sigmaOnf      = 0.65;
dThetaOnSigma = 1.3;
Lnorm         = 0;
feedback      = 0;

% --- Log-Gabor decomposition ---
[EO, ~] = gaborconvolve( ...
    O3, nscale, norient, ...
    minWaveLength, mult, ...
    sigmaOnf, dThetaOnSigma, ...
    Lnorm, feedback);

% --- Energy extraction ---
FGabor = zeros(1, nscale*norient);
k = 1;

for s = 1:nscale
    for o = 1:norient
        FGabor(k) = mean(mean(abs(EO{s,o}).^2));
        k = k + 1;
    end
end

end
