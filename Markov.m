%nth order "Markov Chain"?
order=5;
sequenceLength = initializeSymbolMachine(dataSequence);
%symbolCounts = ones(10^order,9); %Default distribution. Uncomment for the
%first time that you try new data or a new order chain
symbolCounts = readmatrix("Z:\Desktop\Classes\S23\ISS II\"+dataSequence+".csv"); %Prior known distribution from training
last = 0;
for ii = 1:sequenceLength
    probs = symbolCounts(last+1,:)/sum(symbolCounts(last+1,:));
    [thisSymbol,penalty] = symbolMachine(probs);
    symbolCounts(last+1,thisSymbol) = symbolCounts(last+1,thisSymbol) + 1;

    last = mod(last,10^(order-1));
    last = last * 10;
    last = last + thisSymbol;
end
writematrix(symbolCounts,"Z:\Desktop\Classes\S23\ISS II\"+dataSequence+".csv");
reportSymbolMachine;
