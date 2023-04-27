close all; clear; clc;

setA8 = load("sequence_heart2_train.mat");
setB8 = setA8.sequence;

lenB8 = length(setB8);
axe8 = 1:lenB8;

medi8 = fft(setB8);
spec8 = retSpectrum(medi8);
lenA8 = length(spec8);
fIdxLim8 = (lenA8 - 1) / 2;
fInc = 1 / fIdxLim8;

fAxe = -1:fInc:1;

specMag8 = abs(spec8);
specPhs8 = angle(spec8);

figure();
plot(axe8, setB8);
title("Heart 2")
xlabel("Index");
ylabel("Digit");

figure();
plot(fAxe, specMag8);
title("Heart 2 Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(fAxe, specPhs8);
title("Heart 2 Spectrum")
xlabel("Frequency");
ylabel("Digit");

function spec2 = retSpectrum(fftRes)
    % Useful code to tag on the returned result
%     len2 = length(b2);
%     fIdxLim = (len2 - 1) / 2;

    % Coerce input to column vector
    if size(fftRes, 2) > 1
        fftRes = fftRes.';
    end

    % Coerce to odd amounts of indices so that there are equal amounts of
    % frequencies on both sides
    len1 = length(fftRes);
    if (mod(len1, 2) == 0)
        mid = (len1 / 2) + 1;
        proc1 = fftRes + conj(fftRes(mid));
    else
        mid = ((len1 - 1) / 2) + 1;
        proc1 = fftRes;
    end
    midF = mid + 1;

    % Add negative frequencies in front and go to most positive last
    spec2 = [proc1(midF:end); proc1(1:mid)];
end