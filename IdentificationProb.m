function [prob] = IdentificationProb(givenSignal, avgCross)
load('info.mat')
bin = 0;
notfound = true;
while(notfound)
    bin = bin + 1;
    if avgCross >= thresh(bin) && avgCross < thresh(bin+1)
        notfound = false;
    elseif(bin == bins)
        notfound = false;
    end
end
prob = probabilities(givenSignal,bin,givenSignal);