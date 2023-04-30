dataSequenceTrain = 'sequence_solarWind_train';
dataSequenceTest = 'sequence_solarWind_test';

%Defines wether or not it will run on the test or training data.
test = true;
if(test==false)
    sequenceLength = initializeSymbolMachine(dataSequenceTrain);
else
    sequenceLength = initializeSymbolMachine(dataSequenceTest);
end
%Initial symbol probabilities, will change depending on what dataset we are
%testing or training on
initProbs = ones(1,9)/9; %Default distribution. Uncomment for the
%first time that you try new data or a new order chain

%Function to implement autoregressive models
%Decleares the desired lag (How far back the model will look) (Optimize for each dataset)
lag = 8;

%Initial prediction
firstNumber = 5;
%Define standard deviation of normal distribution (Optimize for each dataset)
sdev = 0.32;

%Initializes the last seen values to the mean of the distribution.
last = 55555555;

%Defines the weights of the last n digits seen (Optimize for each dataset)
bArr = [0 0.6 0.15 0.1 0.07 0.04 0.02 0.01 0.01];

%Loop through the dataset
for ii = 1:sequenceLength
    num = last;
    i1 = 0;
    while num ~= 0
        i1 = i1 + 1;
        vec(i1) = mod(num, 10);
        num = floor(num / 10);
    end

    prediction = bArr(1) + sum(bArr(2:end).*vec(1:end));
    % Make forecasted digit (prediction) mean of a new Gaussian distribution and
    % calculate next digit probabilities
    for i1 = 1:9
        if (i1 == 1)
            probs(i1) = areaOfNormalFn(1.5, 1, prediction, sdev, "less than");
        elseif (i1 == 9)
            probs(i1) = areaOfNormalFn(8.5, 1, prediction, sdev, "greater than");
        else
            num1 = i1 + 0.5;
            num2 = i1 - 0.5;
            probs(i1) = areaOfNormalFn(num1, num2, prediction, sdev, "between");
        end
    end
    [symbol,penalty] = symbolMachine(probs);
    
    %Updates last 3 digits
    last = mod(last,10^(lag-1));
    last = last * 10;
    last = last + symbol;
end
reportSymbolMachine;

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
