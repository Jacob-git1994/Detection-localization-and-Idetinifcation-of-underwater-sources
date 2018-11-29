function [ t,crossMax ] = ArivalTime( SNR,tTrue,source,signal )
%uses xcorr to find the most like likely arrival time of the signal
%scale time to apply at a discrete program
scale = 100000;
tRound = round(tTrue*(scale/2));
sourceN(tRound) = 1;
sourceN = conv(source,sourceN);
sourceN = [sourceN zeros(1,scale - length(sourceN))]; %gives us the true signal at its true arrival time

%generate our noise
sigma = sqrt(sum(source.^2)/10^(SNR/10)); %SD of the noise in the water
noise = sigma*randn(size(sourceN)); %assuming guassian noise
sourceN = sourceN + noise;

%cross corralation
[cross,lag] = xcorr(sourceN,signal);

%arrival time should most likely be where the xcorr is max
crossMax = max(cross);
location = (find(cross == crossMax));
t = lag(location)+1;
t = round(t,-1)/(.5*scale);
end

