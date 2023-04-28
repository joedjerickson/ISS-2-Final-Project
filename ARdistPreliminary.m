dataSequenceTrain = 'sequence_nonuniform_train';
dataSequenceTest = 'sequence_nonuniform_test';

%Defines wether or not it will run on the test or training data.
test = false;
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
%Decleares the desired lag (How far back the model will look)
lag = 3;

%upperBound = 9;

%Initial prediction
firstNumber = 5;
%Define characteristic of normal distribution
var = 2;

%Initializes the last seen values to the mean of the distribution.
last = 555;

%Defines the weights of the last n digits seen
bArr = [0, 0.6, 0.3, 0.1];

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
    [symbol,penalty] = symbolMachine(probs);
    %Implement normal distribution ...
    
    %Updates last 3 digits
    last = mod(last,10^(lag-1));
    last = last * 10;
    last = last + thisSymbol;
end
reportSymbolMachine;