% Mixed PPM Scheme Thing
% by Aidan Ferry

dataSequenceTrain = 'sequence_Dickens_train';
dataSequenceTest = 'sequence_Dickens_test';

test = true;
order = 5;
if(test==false)
    sequenceLength = initializeSymbolMachine(dataSequenceTrain);
else
    sequenceLength = initializeSymbolMachine(dataSequenceTest);
end
symbolCounts = ones((10/9)*((10^order)-1),9); %Default distribution. Uncomment for the
%first time that you try new data or a new order chain
%symbolCounts = readmatrix("Z:\Desktop\Classes\S23\ISS II\"+dataSequenceTrain+".csv"); %Prior known distribution from training
last = 0;
t=1:1:order;
weights = t;
for ii = 1:sequenceLength
    probs = zeros(1,9);
    for j = 1:order
        probs = probs + weights(j)*symbolCounts((10/9)*(10^(j-1)-1)+mod(last,10^j)+1,:)/sum(symbolCounts((10/9)*(10^(j-1)-1)+mod(last,10^j)+1,:));
    end
    probs = probs./sum(probs);
    [thisSymbol,penalty] = symbolMachine(probs);
    for j = 1:order
        symbolCounts((10/9)*(10^(j-1)-1)+mod(last,10^j)+1,thisSymbol) = symbolCounts((10/9)*(10^(j-1)-1)+mod(last,10^j)+1,thisSymbol) + 1;
    end
    
    last = mod(last,10^(order-1));
    last = last * 10;
    last = last + thisSymbol;
end
if(test==false)
    writematrix(symbolCounts,"Z:\Desktop\Classes\S23\ISS II\"+dataSequenceTrain+".csv");
end
reportSymbolMachine;
