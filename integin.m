%obtención de G y H de las diagonales
%la función de Green es integrable en estos puntos, pudiendo obtener su
%valor analítico
function [G,H]=integin(x0,y0,x1,y1,x2,y2,K,tol)
H = 0.5;
L=sqrt((x2-x1)^2+(y2-y1)^2);

b=K*L/2;
nterm=20;
I1=besselj(0,b)+pi/2*(struve(0,b,nterm)*besselj(1,b)-struve(1,b,nterm)*besselj(0,b));
I2=bessely(0,b)+pi/2*(struve(0,b,nterm)*bessely(1,b)-struve(1,b,nterm)*bessely(0,b));
G=-1i/4*L*(I1-1i*I2);
%comprobacion de divergencias para evitar bugs
TF = isfinite(G);
if TF == 0
    disp('inf de G')
    disp('I1')
    disp(I1)
    disp('I2')
    disp(I2)
end

return;

function f=struve(v,x,n)
% Calculates the Struve Function
%
% struve(v,x)
% struve(v,x,n)
%
% H_v(x) is the struve function and n is the length of
% the series calculation (n=100 if unspecified)
%
% from: Abramowitz and Stegun: Handbook of Mathematical Functions
% 		http://www.math.sfu.ca/~cbm/aands/page_496.htm

if nargin<3
    n=100;
end

k=0:n;

x=x(:)';
k=k(:);

xx=repmat(x,length(k),1);
kk=repmat(k,1,length(x));

TOP=(-1).^kk;
BOT=gamma(kk+1.5).*gamma(kk+v+1.5);
RIGHT=(xx./2).^(2.*kk+v+1);
FULL=TOP./BOT.*RIGHT;

f=sum(FULL);
%construccion de la funcion como sumatorio