close all; clear; clc;

a1 = [0, 0, 1, 0, 1, 2, 0, 1, 2, 3, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 8];
len1 = length(a1);

b1 = fft(a1);

b2 = retSpectrum(b1);
len2 = length(b2);
fIdxLim = (len2 - 1) / 2;

b3 = abs(b2);
b4 = angle(b2);

c1 = 0:1:(len1-1);
c2 = -fIdxLim:1:fIdxLim;

figure();
plot(c1, a1);

figure();
plot(c2, b3);

figure();
plot(c2, b4);

function spec2 = retSpectrum (fftRes)
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
        proc1 = [fftRes; conj(fftRes(mid))];
    else
        mid = ((len1 - 1) / 2) + 1;
        proc1 = fftRes;
    end
    midF = mid + 1;

    % Add negative frequencies in front and go to most positive last
    spec2 = [proc1(midF:end); proc1(1:mid)];
end