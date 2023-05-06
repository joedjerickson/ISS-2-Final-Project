% Modified from Mike Wakin, who originated the ancestor file - 2023-03-07
% Charles Vath

close all; clear; clc;

% sdev and buildupCount for various distributions:
% 'sequence_DIAtemp_train.mat': Around 0.8 sdev, 16 buildupCounts
% 'sequence_DIAwind_train.mat':Around 1.25 sdev, 30 buildupCounts
% 'sequence_heart2_train.mat': Around 0.35 sdev, 11 buildupCounts
%

datasetArr = [
    %'sequence_DIAtemp_train.mat'
    %'sequence_DIAtemp_test.mat'    
    'sequence_DIAwind_train.mat'
    %'sequence_DIAwind_test.mat'    
    %'sequence_heart2_train.mat'
    %'sequence_heart2_test.mat'
];

len1 = size(datasetArr, 1);

sdev = 1.25;
%sdevArr = 1:0.05:2;

ratAmt = 0.999;
ratInitAt = 1000;
ratLim = 0.5;
ratchet = true;

buildup = true;
buildupCount = 30;
%buildupCountArr = 30:1:40;
nRuns = 1;
%nRuns = length(sdevArr);
%nRuns = length(buildupCountArr);
ppbArr = zeros(len1, nRuns);

for i1 = 1:len1
    datasetStr = datasetArr(i1, :);
    for i2 = 1:nRuns
        %sdev = sdevArr(i2);
        %buildupCount = buildupCountArr(i2);
        ppbArr(i1, i2) = runSymMachine(datasetStr, sdev, ratchet, ratAmt, ratLim, ratInitAt, buildup, buildupCount, false);
    end
end

ret = areaOfNormalFn(7.5, 6.5, 6.911, 0.25, "between");

function ppb = runSymMachine(datasetStr, sdev, ratchet, ratAmt, ratLim, ratInitAt, buildup, buildupCount, normPick)
% Initialize Symbol Machine with one of the provided sequences
sequenceLength = initializeSymbolMachine(datasetStr);

% Initial pmf and setup
probs = ones(9, 1) ./ 9;
digs = zeros(sequenceLength, 1);
digs(1, 1) = 5;

% svar = 0.25;
% sdev = sqrt(svar);

symbolCounts = ones(1,9); 
penaltyArr = zeros(sequenceLength, 1);
probArr = zeros(sequenceLength, 9);
prDigArr = zeros(sequenceLength, 1);
prDigArr(1) = 5;

%% Run symbol machine
for i1 = 1:sequenceLength
    %% Prepare new pmf
    % Adjust sample mean and sample variance if wanted

    % Standard deviation ratcheting as FFT spectrum predictions improve
    if ((ratchet) && (i1 > ratInitAt))
        sdev = sdev*ratAmt;
        if (sdev < ratLim)
            sdev = ratLim;
        end
    end

    % Forecast next digit with frequency domain estimation
    l1 = i1 + 1;
    if i1 > 1
        setA = digs(2:i1, 1);
        proc1 = fft(setA);
        proc2 = ifft(proc1, i1);
        prDig = abs(proc2(i1));
        prDigArr(l1) = prDig;
    else
        prDig = 5;
        prDigArr(2) = 5;
    end

    if (i1 == 31)
        disp(size(proc1));
        disp(size(proc2));

        disp(digs(1:i1, 1))
        disp(proc1);
        disp(proc2);
    end

    % Make forecasted digit mean of a new Gaussian distribution and
    % calculate next digit probabilities
    if buildup
        if (i1 < buildupCount)
            useFFT = false;
        else
            useFFT = true;
        end
    else
        useFFT = true;
    end

    if ((useFFT) && (normPick))
        for i2 = 1:9
            if (i2 == 1)
                probs(i2) = areaOfNormalFn(1.5, 1, prDig, sdev, "less than");
            elseif (i2 == 9)
                probs(i2) = areaOfNormalFn(8.5, 1, prDig, sdev, "greater than");
            else
                num1 = i2 + 0.5;
                num2 = i2 - 0.5;
                probs(i2) = areaOfNormalFn(num1, num2, prDig, sdev, "between");
            end
        end
    elseif (useFFT)
        for i2 = 1:9
            probs(i2) = areaOfDist1(i2, prDig);
        end        
        errH1 = sum(probs);
        if (errH1 ~= 1)
            probs = probs ./ errH1;
        end
    else
        if (i1 ~= 1)
            symbolCounts(newSym) = symbolCounts(newSym) + 1;
        end
        probs = symbolCounts./sum(symbolCounts);
    end

    %% Score pmf for next digit
    [newSym,penalty] = symbolMachine(probs);
    penaltyArr(i1) = penalty;
    probArr(i1, :) = probs;
    
    % Increment digits read and add new digit to list
    digs(l1, 1) = newSym;

end

%% Reporting and post-processing
reportSymbolMachine;
ppb = sum(penaltyArr) / sequenceLength;

% Graphing
idxArr = 1:sequenceLength;
figure();
hold on
plot(idxArr, digs(1:end-1), "--", "Color", [0.2, 0.2, 0.3],"Marker", "+",'MarkerEdgeColor',[0.5,0.5,0.5],'MarkerFaceColor',[0.5,0.5,0.5], "MarkerSize",5);
plot(idxArr, prDigArr(1:end-1), ":", "Color", [0.7, 0.1, 0],"Marker", "*", 'MarkerEdgeColor',[0.4,0.7,0.1],'MarkerFaceColor',[0.4,0.7,0.1], "MarkerSize",4);
hold off
title("Digits and Predicted Digits Received Over Time");
xlabel("Discrete Time Samples");
ylabel("Digit / Predicted Digit");
legend("Digit", "Predicted Digit");

figure();
plot(idxArr, penaltyArr);
title("Penalty Over Time");
xlabel("Discrete Time Samples");
ylabel("Penalty");

figure();
digDiff = prDigArr(1:end-1) - digs(1:end-1);
plot(idxArr, digDiff);
title("Discrepancy Between Predicted and Actual Digit");
xlabel("Discrete Time Samples");
ylabel("Discrepancy");

disp(size(digs(1:end-1)));
disp(size(prDigArr(1:end-1)));

figure();
hold on
for i1 = 1:9
    plot(idxArr, probArr(:, i1));
end
title("Probabilities of Digits Over Time");
xlabel("Discrete Time Samples");
ylabel("Probability of Digit");
legend( ["Digit 1 Probabilities" 
        "Digit 2 Probabilities"
        "Digit 3 Probabilities"
        "Digit 4 Probabilities"
        "Digit 5 Probabilities"
        "Digit 6 Probabilities"
        "Digit 7 Probabilities"
        "Digit 8 Probabilities"
        "Digit 9 Probabilities"]);
hold off

end

%% Other Functions
function [avg, sVar] = adaptiveSummaryStats(prevDigs, idx)
    avg = sum(prevDigs) / idx;
    avgDev = prevDigs(1:idx, 1) - avg;
    if idx ~= 1
        sVar = sum((avgDev.^2)) / (idx - 1);
    else
        sVar = 32;
    end
end

function ret = areaOfDist1(num, cent)
    z = abs(num - cent);
    mult = 0.9 / 1.5;
    ret = 1/90 + zScoreDist1Fn(z).*mult;
end

% Function to compute the area under the Normal distribution given the z-score
function ret = zScoreDist1Fn(z)
    if z < 0.25
        ret = 1;
    elseif z > 1.25
        ret = 0;
    else
        ret = 1.25 - z;
    end
end

function ret = areaOfNormalFn(baseNum, optLower, mean, sdev, opt)
% baseNum: the baseline number, enter this number in as the number for less
% than or greater than calculations, and as the higher number if
% looking for area between numbers
% optLower: optional lower number, despite being optional a value must be
% passed in always, but the number passed in is only used if between option
% is selected
% mean: distribution mean
% sdev: standard deviation
% opt: option of area less than baseNum, area greater than baseNum, and area between baseNum and optLower

    z1 = (baseNum - mean) / sdev;
    z2 = (optLower - mean) / sdev;

    if (opt == "less than")
        ret = zScoreNormalFn(z1);
    elseif (opt == "greater than")
        ret = 1 - zScoreNormalFn(z1);
    elseif (opt == "between")
        ret = zScoreNormalFn(z1) - zScoreNormalFn(z2);
    else
        disp("ERROR NO SUCH OPTION FOUND");
    end
end

% Function to compute the area under the Normal distribution given the z-score
function res = zScoreNormalFn(z)
    res = 0.5.*(1+erf(z./sqrt(2)));
end
