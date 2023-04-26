close all; clear; clc;

setA1 = load("sequence_uniform_train.mat");
setA2 = load("sequence_nonuniform_train.mat");
setA3 = load("sequence_selfadapt_train.mat");
setA4 = load("sequence_DIAtemp_train.mat");
setA5 = load("sequence_DIAwind_train.mat");
setA6 = load("sequence_solarWind_train.mat");
setA7 = load("sequence_heart1_train.mat");
setA8 = load("sequence_heart2_train.mat");
setA9 = load("sequence_Hawaiian_train.mat");
setA10 = load("sequence_Dickens_train.mat");

setB1 = setA1.sequence;
setB2 = setA2.sequence;
setB3 = setA3.sequence;
setB4 = setA4.sequence;
setB5 = setA5.sequence;
setB6 = setA6.sequence;
setB7 = setA7.sequence;
setB8 = setA8.sequence;
setB9 = setA9.sequence;
setB10 = setA10.sequence;

lenB1 = length(setB1);
lenB2 = length(setB2);
lenB3 = length(setB3);
lenB4 = length(setB4);
lenB5 = length(setB5);
lenB6 = length(setB6);
lenB7 = length(setB7);
lenB8 = length(setB8);
lenB9 = length(setB9);
lenB10 = length(setB10);

axe1 = 1:lenB1;
axe2 = 1:lenB2;
axe3 = 1:lenB3;
axe4 = 1:lenB4;
axe5 = 1:lenB5;
axe6 = 1:lenB6;
axe7 = 1:lenB7;
axe8 = 1:lenB8;
axe9 = 1:lenB9;
axe10 = 1:lenB10;

spec1 = fft(setB1);
spec2 = fft(setB2);
spec3 = fft(setB3);
spec4 = fft(setB4);
spec5 = fft(setB5);
spec6 = fft(setB6);
spec7 = fft(setB7);
spec8 = fft(setB8);
spec9 = fft(setB9);
spec10 = fft(setB10);

specMag1 = abs(setB1);
specMag2 = abs(setB2);
specMag3 = abs(setB3);
specMag4 = abs(setB4);
specMag5 = abs(setB5);
specMag6 = abs(setB6);
specMag7 = abs(setB7);
specMag8 = abs(setB8);
specMag9 = abs(setB9);
specMag10 = abs(setB10);

specPhs1 = angle(setB1);
specPhs2 = angle(setB2);
specPhs3 = angle(setB3);
specPhs4 = angle(setB4);
specPhs5 = angle(setB5);
specPhs6 = angle(setB6);
specPhs7 = angle(setB7);
specPhs8 = angle(setB8);
specPhs9 = angle(setB9);
specPhs10 = angle(setB10);

figure();
plot(axe1, setB1);
title("Uniform")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe1, specMag1);
title("Uniform Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe2, setB2);
title("Non-uniform")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe2, specMag2);
title("Non-uniform Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe3, setB3);
title("Self-adapt")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe3, specMag3);
title("Self-adapt Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe4, setB4);
title("DIA Temp")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe4, specMag4);
title("DIA Temp Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe5, setB5);
title("DIA Wind")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe5, specMag5);
title("DIA Wind Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe6, setB6);
title("Solar Wind")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe6, specMag6);
title("Solar Wind Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe7, setB7);
title("Heart 1")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe7, specMag7);
title("Heart 1 Spectrum")
xlabel("Frequency");
ylabel("Digit");

figure();
plot(axe8, setB8);
title("Heart 2")
xlabel("Index");
ylabel("Digit");

figure();
plot(axe8, specMag8);
title("Heart 2 Spectrum")
xlabel("Frequency");
ylabel("Digit");

% figure();
% plot(axe9, setB9);
% title("Hawaiian")
% xlabel("Index");
% ylabel("Digit");

% figure();
% plot(axe9, specMag9);
% title("Hawaiian Dataset Spectrum")
% xlabel("Frequency");
% ylabel("Digit");

% figure();
% plot(axe10, setB10);
% title("Dickens")
% xlabel("Index");
% ylabel("Digit");

% figure();
% plot(axe10, specMag10);
% title("Dickens Dataset Spectrum")
% xlabel("Frequency");
% ylabel("Digit");

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
        proc1 = fftRes + conj(fftRes(mid));
    else
        mid = ((len1 - 1) / 2) + 1;
        proc1 = fftRes;
    end
    midF = mid + 1;

    % Add negative frequencies in front and go to most positive last
    spec2 = [proc1(midF:end); proc1(1:mid)];
end