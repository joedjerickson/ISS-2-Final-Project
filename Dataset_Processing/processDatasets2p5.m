%% Dataset Processor Version 2
% Charles Vath
% Created 04/25/2023
% Displays graphs of datasets used in the EENG 311 ISS 2 final project,
% such as time domain and frequency domain graphs

close all; clear; clc;

statArr = zeros(20, 2); % sample mean and sample variance

statArr = procDataset("sequence_uniform_train.mat", "", statArr, 1);
statArr = procDataset("sequence_nonuniform_train.mat", "", statArr, 2);
statArr = procDataset("sequence_selfadapt_train.mat", "", statArr, 3);
statArr = procDataset("sequence_DIAtemp_train.mat", "", statArr, 4);
statArr = procDataset("sequence_DIAwind_train.mat", "", statArr, 5);
statArr = procDataset("sequence_solarWind_train.mat", "", statArr, 6);
statArr = procDataset("sequence_heart1_train.mat", "", statArr, 7);
statArr = procDataset("sequence_heart2_train.mat", "", statArr, 8);
%statArr = procDataset("sequence_Hawaiian_train.mat", "", statArr, 9);
%statArr = procDataset("sequence_Dickens_train.mat", "", statArr, 10);

statArr = procDataset("sequence_uniform_test.mat", "", statArr, 11);
statArr = procDataset("sequence_nonuniform_test.mat", "", statArr, 12);
statArr = procDataset("sequence_selfadapt_test.mat", "", statArr, 13);
statArr = procDataset("sequence_DIAtemp_test.mat", "", statArr, 14);
statArr = procDataset("sequence_DIAwind_test.mat", "", statArr, 15);
statArr = procDataset("sequence_solarWind_test.mat", "", statArr, 16);
statArr = procDataset("sequence_heart1_test.mat", "", statArr, 17);
statArr = procDataset("sequence_heart2_test.mat", "", statArr, 18);
%statArr = procDataset("sequence_Hawaiian_test.mat", "", statArr, 19);
%statArr = procDataset("sequence_Dickens_test.mat", "", statArr, 20);

function statArr = procDataset(datasetStr, extn, statArr, idx)
    strA1 = datasetStr + extn;

    setA1 = load(strA1);

    setA2 = setA1.sequence;

    lenA = length(setA2);
    avgDig = sum(setA2) / lenA;
    setA3 = setA2 - avgDig;

    axe = 0:(lenA-1);

    proc1 = fft(setA2);
    proc2 = fft(setA3);

    spec1 = retSpectrum(proc1);
    spec2 = retSpectrum(proc2);

    freqLen = length(spec1);

    fIdxLim = (freqLen - 1) / 2;
    fInc = 0.5 / fIdxLim;

    fAxe = (-0.5:fInc:0.5).'; % Anything above half the sampling frequency gets downsampled

    specMag1 = abs(spec1);
    specPhs1 = angle(spec1);

    specMag2 = abs(spec2);
    specPhs2 = angle(spec2);

    figure();
    plot(axe, setA2);
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

%     figure();
%     plot(fAxe, specPhs1);
%     strA4 = datasetStr + " Phase Spectrum";
%     title(strA4, "Interpreter", "none")
%     xlabel("Frequency");
%     ylabel("Digit");

    sVar = sum((setA3.^2)) / (lenA - 1);
    statArr(idx, 1) = avgDig;
    statArr(idx, 2) = sVar;

%     figure();
%     plot(fAxe, specMag2);
%     strA5 = datasetStr + " Absolute Value Spectrum w/ DC Scrubbed";
%     title(strA5, "Interpreter", "none")
%     xlabel("Frequency");
%     ylabel("Digit");
% 
%     figure();
%     plot(fAxe, specPhs2);
%     strA6 = datasetStr + " Phase Spectrum w/ DC Scrubbed";
%     title(strA6, "Interpreter", "none")
%     xlabel("Frequency");
%     ylabel("Digit");

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
    if (mod(len1, 2) == 0) % If even number of points
        mid = (len1 / 2) + 1; % The 'middle' (excluding the DC component)
        midF = mid + 1;
        proc1 = [fftRes(1:mid); conj(fftRes(mid)); fftRes(midF:end)]; % add the middle excluded on the negative side of the frequency domain
    else
        mid = ((len1 - 1) / 2) + 1;
        midF = mid + 1;
        proc1 = fftRes;
    end

    % Add negative frequencies in front and go to most positive last
    spec2 = [proc1(midF:end); proc1(1:mid)];
end
