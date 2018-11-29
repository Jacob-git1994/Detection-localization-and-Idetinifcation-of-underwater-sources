function [ x,y,z ] = multilateration( recivers,t )
%Three dimentional multilateration
c = 1500; %speed of sound in water

%How much the first reciver must be shifted by
xShift = recivers(1,1);
yShift = recivers(1,2);
zShift = recivers(1,3);

%save the new pairs of recivers
reciversS = zeros(size(recivers));

%shifts the first reciver so it will be zero
reciversS(:,1) = recivers(:,1) - xShift;
reciversS(:,2) = recivers(:,2) - yShift;
reciversS(:,3) = recivers(:,3) - zShift;

%difference in Times
Dt2=t(2)-t(1);
Dt3=t(3)-t(1);
Dt4=t(4)-t(1);
Dt5=t(5)-t(1);

%Set up individual parts for better readability
x2 = reciversS(2,1); y2 = reciversS(2,2); z2 = reciversS(2,3); 
x3 = reciversS(3,1); y3 = reciversS(3,2); z3 = reciversS(3,3); 
x4 = reciversS(4,1); y4 = reciversS(4,2); z4 = reciversS(4,3); 
x5 = reciversS(5,1); y5 = reciversS(5,2); z5 = reciversS(5,3); 

%create a matrix 
A(1,1)=2*x3/c/Dt3-2*x2/c/Dt2; 
A(1,2)=2*y3/c/Dt3-2*y2/c/Dt2;
A(1,3)=2*z3/c/Dt3-2*z2/c/Dt2;
D(1,1)=c*-(Dt3-Dt2)+(x3^2+y3^2+z3^2)/c/Dt3-(x2^2+y2^2+z2^2)/c/Dt2;

A(2,1)=2*x4/c/Dt4-2*x2/c/Dt2;
A(2,2)=2*y4/c/Dt4-2*y2/c/Dt2;
A(2,3)=2*z4/c/Dt4-2*z2/c/Dt2;
D(2,1)=c*-(Dt4-Dt2)+(x4^2+y4^2+z4^2)/c/Dt4-(x2^2+y2^2+z2^2)/c/Dt2;

A(3,1)=2*x5/c/Dt5-2*x2/c/Dt2;
A(3,2)=2*y5/c/Dt5-2*y2/c/Dt2;
A(3,3)=2*z5/c/Dt5-2*z2/c/Dt2;
D(3,1)=c*-(Dt5-Dt2)+(x5^2+y5^2+z5^2)/c/Dt5-(x2^2+y2^2+z2^2)/c/Dt2;

%solve augmented matrix for x, y, z
b = A\D;%(inv(A'*A))*A'*D;
warning('off','all');
x = b(1,1) + xShift;
y = b(2,1) + yShift;
z = b(3,1) + zShift;

end

