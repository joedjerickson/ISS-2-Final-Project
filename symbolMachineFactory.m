% Modified from Mike Wakin, who originated the ancestor file - 2023-03-07
% Charles Vath

close all; clear; clc;

datasetArr = [
    'sequence_heart2_train.mat'
];

len1 = size(datasetArr, 1);
ppbArr = zeros(len1, 1);
nRuns = 1;

for i1 = 1:len1
    datasetStr = datasetArr(i1, :);
    for i2 = 1:nRuns
        ppbArr(i1) = runSymMachine(datasetStr);
    end
end

function ppb = runSymMachine(datasetStr)
% Initialize Symbol Machine with one of the provided sequences
sequenceLength = initializeSymbolMachine(datasetStr);

% Initial pmf and setup
probs = ones(9, 1) ./ 9;
symbolCounts = ones(9, 1);
idx = 0;
prevDigs = zeros(sequenceLength, 1);

avg = 6.981111111111111;
svar = 0.25;
sdev = sqrt(svar);
aggalty = 0;

penaltyArr = zeros(sequenceLength, 1);
probArr = zeros(sequenceLength, 9);
prDigArr = zeros(sequenceLength, 1);

%% Run symbol machine
for i1 = 1:sequenceLength
    %% Score pmf for next digit
    [newSym,penalty] = symbolMachine(probs);
    penaltyArr(i1) = penalty;
    probArr(i1, :) = probs;

    %% Prepare new pmf
    % Increment digits read and add new digit to list
    idx = idx + 1;
    prevDigs(idx, 1) = newSym;

    % Adjust sample mean and sample variance if wanted
%     [avg, sVar] = adaptiveSummaryStats(prevDigs, idx);
%     sdev = sqrt(sVar);

    % Variance ratcheting as FFT spectrum predictions improve

    % Forecast next digit with frequency domain estimation
    setA = prevDigs(1:idx);
    proc1 = fft(setA);
    l1 = idx + 1;
    proc2 = ifft(proc1, l1);
    prDig = abs(proc2(l1));
    prDigArr(i1) = prDig;

    % Make forecasted digit mean of a new Gaussian distribution and
    % calculate next digit probabilities
    for i1 = 1:9
        if (i1 == 1)
            probs(i1) = areaOfNormalFn(1.5, 1, prDig, sdev, "less than");
        elseif (i1 == 9)
            probs(i1) = areaOfNormalFn(8.5, 1, prDig, sdev, "greater than");
        else
            num1 = i1 + 0.5;
            num2 = i1 - 0.5;
            probs(i1) = areaOfNormalFn(num1, num2, prDig, sdev, "between");
        end
    end

end

%% Reporting and post-processing
reportSymbolMachine;
ppb = aggalty / sequenceLength;

% Graphing
idxArr = 1:sequenceLength;
figure();
hold on
plot(idxArr, penaltyArr);
plot(idxArr, prevDigs)
plot(idxArr, prDigArr)
hold off
title("Penalty Over Time With Digits and Predicted Digits Received Over Time");
xlabel("Discrete Time Samples");
ylabel("Penalty / Digit / Predicted Digit");
legend("Penalty", "Digit", "Predicted Digit");

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
