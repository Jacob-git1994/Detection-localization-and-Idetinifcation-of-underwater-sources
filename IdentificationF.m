function [  ] = IdentificationF( signal,SNR )
%Save information for identification
N = 1000;
samples = 50000;
duration = length(signal(1,:));
numSources = size(signal,1);

t_exact = 0.5;
t_round = round(t_exact*samples);

source = zeros(numSources,samples-duration+1);
source(:,t_round)=1;

for i=1 : numSources
   csource(i,:) =  conv(signal(i,:),source(1,:));
end

sigma = sqrt(sum(signal(1,:).^2)./10.^(SNR/10));

bins = 20;
numSources = size(source,1);

totalNum = zeros(numSources+1, bins);
correct = zeros(numSources+1, bins);
incorrect = zeros(numSources+1, bins, numSources);

thresh = linspace(0.5,2,bins+1);

h = waitbar(0,'Generating Identifications for Signals');
for i=1:N
noise = sigma*randn(size(csource(1,:)));
        
    for buriedS = 1:numSources+1
        waitbar(i/N);
        if buriedS == numSources+1
            sourceNoise(buriedS,:) = noise;
        else
            sourceNoise(buriedS,:) = csource(buriedS,:) + noise;    
        end

        for checkS = 1:numSources
            crossSource(buriedS,checkS,:) = xcorr(sourceNoise(buriedS,:),signal(checkS,:));
            crossSourceShort(buriedS,checkS,:) = crossSource(buriedS,checkS,samples-duration:end);
            maxValSource(buriedS,checkS,i) = max(crossSourceShort(buriedS,checkS,:));
        end
        guess = find(maxValSource(buriedS,:,i) == max(maxValSource(buriedS,:,i)));

        for checkS = 1:numSources
            for j=1:bins
                if maxValSource(buriedS,checkS,i) >= thresh(j) && maxValSource(buriedS,checkS,i) < thresh(j+1) %sort into approriate bin
                    totalNum(checkS, j) = totalNum(checkS, j) + 1; %add to total number for guessing our "guess" source
                    if checkS == buriedS 
                        correct(checkS, j) = correct(checkS, j) + 1; 
                    else
                        incorrect(buriedS,j,checkS) = incorrect(buriedS,j,checkS) + 1; %count which source it incorrectly guessed
                    end
                end
            end
        end
    end
end

for i = 1:bins
    array(i) = thresh(i);
end

for guess = 1:numSources %for each source, plot probability of proper identification vs. difference between best and second best
    for s2 = 1:numSources
        if s2 == guess
            probabilities(s2,:,guess) = correct(guess,:)./totalNum(guess,:); %number of correctly guessing each source / number of times we guessed each source (correctly or incorrectly
        else
            probabilities(s2,:,guess) = incorrect(s2,:,guess)./totalNum(guess,:); %number of incorrectly guessing each source / number of times we guessed each source (correctly or incorrectly
        end
    end    
    
end
close(h);
save('info.mat','thresh','bins','probabilities');
end

