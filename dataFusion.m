function [ xMax,yMax,zMax ] = dataFusion( recivers,t )
%Uses data fustion to find the most likely location of the source
i = 1; count = 1;
while i < 10000 && count < 200000
   %gets a random set of recivers and times for multilateration
   random =randperm(length(t),length(t));
   currentRecivers = recivers((random(1:5))',:,:);
   currentT = t(1,random(1:5));
   
   %multilateration
   [x,y,z] = multilateration(currentRecivers,currentT);
   
   %filters out values that are not practical
   if z <= 50 && z >= -300 && x > 50 && x < 2000
       X(i) = x; Y(i) = y; Z(i) = z;
       i = i + 1;
   end
   count = count + 1;
end
%generate our pmf
[fx , XPDF] = ksdensity(X,[0:1:1500]);
[fy , YPDF ] = ksdensity(Y,[-1500:1:1500]);
[fz , ZPDF ] = ksdensity(Z,[-300:1:-50]);

xMax = XPDF(fx == max(fx));
yMax = YPDF(fy == max(fy));
zMax = ZPDF(fz == max(fz));

% figure
% plot(XPDF,fx);
% figure;
% plot(YPDF,fy);
% figure;
% plot(ZPDF,fz);
end

