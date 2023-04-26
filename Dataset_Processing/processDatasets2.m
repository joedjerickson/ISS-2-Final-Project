%% Dataset Processor Version 2
% Charles Vath
% Created 04/25/2023
% Displays graphs of datasets used in the EENG 311 ISS 2 final project,
% such as time domain and frequency domain graphs

close all; clear; clc;

procDataset("sequence_uniform_train.mat", "");
procDataset("sequence_nonuniform_train.mat", "");
procDataset("sequence_selfadapt_train.mat", "");
procDataset("sequence_DIAtemp_train.mat", "");
procDataset("sequence_DIAwind_train.mat", "");
procDataset("sequence_solarWind_train.mat", "");
procDataset("sequence_heart1_train.mat", "");
procDataset("sequence_heart2_train.mat", "");
procDataset("sequence_Hawaiian_train.mat", "");
procDataset("sequence_Dickens_train.mat", "");

function procDataset(datasetStr, extn)
    strA1 = datasetStr + extn;

    setA1 = load(strA1);

    setA2 = setA1.sequence;

    lenA1 = length(setA2);
    axe1 = 0:(lenA1-1);

    proc1 = fft(setA2);
    spec1 = retSpectrum(proc1);

    fIdxLim1 = (lenA1 - 1) / 2;
    fInc = 1 / fIdxLim1;

    fAxe = -1:fInc:1;

    specMag1 = abs(spec1);
    specPhs1 = angle(spec1);

    figure();
    plot(axe1, setA2);
    strA2 = datasetStr + " in Time Domain";
    title(strA2, "Interpreter", "none")
    xlabel("Index");
    ylabel("Digit");

    figure();
    plot(fAxe, specMag1);
    strA3 = datasetStr + " Absolute Value Spectrum";
    title(strA3, "Interpreter", "none")
    xlabel("Frequency");
    ylabel("Digit");

    figure();
    plot(fAxe, specPhs1);
    strA4 = datasetStr + " Phase Spectrum";
    title(strA4, "Interpreter", "none")
    xlabel("Frequency");
    ylabel("Digit");

end

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