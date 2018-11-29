%Jacob Dresher
clear all;
close all;
clc;
%save seed to replicate results
rng(123,'v5uniform');

%signal to noise ratio
SNR = 14;

%number of realizations
N = 10;

%speed of sound in water
c = 1500;
%generate our signals
X = linspace(-1,1,5000);
sig(1,:) = sinc(100000*X);
sig(2,:) = sinc(60000*X);
sig(3,:) = tan(X);%sinc(15*X);
%Divide by norm so each signal has power = 1
for m=1 : size(sig,1)
    sig(m,:) = sig(m,:) / norm(sig(m,:));
end
%IdentificationF(sig,SNR); %generates probablities for each signal - only uncomment if you change the SNR
source = sig(1,:);

%generate our recivers (in general we usually pick what we want)
numOfRecivers = 30;
recivers = zeros(numOfRecivers,3);
for i=1 : numOfRecivers
   recivers(i,:) = [randi([0 1500],1,1) randi([-1500 1500],1,1) randi([-300 -10],1,1)];
end

%generate the position of our source
sourceLocation = [randi([0 1500],1) randi([-1500 1500],1) randi([-300 -60],1)];

%calculates arrival times
t = zeros(1,numOfRecivers);
for i=1 : size(recivers,1)
    t(i) = norm(sourceLocation' - recivers(i,:)')/c;
end

%itterate over the different signals
seed = rng;
receivedTime = zeros(size(sig,1),numOfRecivers);
crossMax = zeros(size(sig,1),numOfRecivers,N);
for i=1 : size(sig,1)
   rng(seed);
   q = waitbar(0,['Locating Signal Number ' num2str(i)]);
   %monte carlo realizations
   for n=1 : N
       waitbar(n/N);
       for j=1 : numOfRecivers
          [receivedTime(i,j),crossMax(i,j,n)] = ArivalTime(SNR,t(1,j),source,sig(i,:));
       end
       [x(i,n),y(i,n),z(i,n)] = dataFusion(recivers,receivedTime(i,:));
   end
   close(q);
end

%probablities of each signal
for s=1 : size(sig,1)
   for r = 1 : numOfRecivers
       avgCross(s,r) = mean(crossMax(s,r,:));
   end
   avgPerSig(s) = mean(avgCross(s,:));
   probPerSig(s) = IdentificationProb(s,avgPerSig(s));
end
probPerSig = round(100*probPerSig);

%plotting source and recivers
figure;
plot3(sourceLocation(1),sourceLocation(2),sourceLocation(3),'yo','MarkerSize',10,'LineWidth',4);hold on 
plot3(recivers(:,1)',recivers(:,2)',recivers(:,3),'wp');

%reference grid
%lines for distance reference
plot3([0 0],[-1500 1500],[-300 -300],'k');
plot3([0 1500],[1500 1500],[-300 -300],'k');
plot3([1500 1500],[-1500 1500],[-300 -300],'k');
plot3([0 1500],[-1500 -1500],[-300 -300],'k');

plot3([0 0],[-1500 1500],[100 100],'y','MarkerSize',10,'LineWidth',5);
plot3([0 1500],[1500 1500],[100 100],'k');
plot3([1500 1500],[-1500 1500],[100 100],'k');
plot3([0 1500],[-1500 -1500],[100 100],'k');

plot3([0 0],[-1500 -1500],[-300 100],'k');
plot3([0 0],[1500 1500],[-300 100],'k');
plot3([1500 1500],[-1500 -1500],[-300 100],'k');
plot3([1500 1500],[1500 1500],[-300 100],'k');

%plots all the points of each signal for a signal based on realizations
h(1) = plot3(x(1,:),y(1,:),z(1,:),'r*','LineWidth',2); legend(h(1),'Signal 1');
h(2) = plot3(x(2,:),y(2,:),z(2,:),'k*','LineWidth',2);
h(3) = plot3(x(3,:),y(3,:),z(3,:),'g*','LineWidth',2);
legend(h(:),{['Signal1 ' num2str(probPerSig(1)) '%'] ['Signal2 ' num2str(probPerSig(2)) '%'] ['Signal3 ' num2str(probPerSig(3)) '%']});

%adds a cute color and sets the axis
axis([0 1500 -1500 1500 -300 100]);
set(gca,'color','b');
xlabel('Range');
ylabel('Shore');
zlabel('Depth')
title(['Average SNR = ',num2str(SNR)]);
hold off;
