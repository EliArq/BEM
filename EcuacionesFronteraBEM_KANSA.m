%Construcción del sistema matricial H*p = i*rho*w*G*v
%la incógnita es la matriz de presión
%el mallado es dependiente de la frecuencia y la geometría, si la geometría
%es suave, el mallado es menos denso, y viceversa. 
function [X,rx,ry]=EcuacionesFronteraBEM_KANSA(xm,ym,x0,y0,x1,y1,K,V,rho,omega,interior,numero,freq)
%Inicializamos matrices
npb=numel(xm);
%Vectores CHIEF
xch=[linspace(min(xm),max(xm),npb)];
ych = [linspace(min(ym),max(ym),npb)];

npch=numel(xch);   
G=zeros(npb+npch,npb);
H=zeros(npb+npch,npb);
for ii=1:npb
    % Cargamos puntos medios
    xp=xm(ii);
    yp=ym(ii);
    [Gb,Hb]=integoff(xp,yp,x0,y0,x1,y1,K,16);
    G(ii,:)=Gb;
    H(ii,:)=Hb;
    %los de encima y debajo de las diagonales  
    [Gb,Hb]=integin(xp,yp,x0(ii),y0(ii),x1(ii),y1(ii),K,1e-4);
    %los de las diagonales
    Hb=0.5; %por comodidad se toma
    G(ii,ii)=Gb;
    H(ii,ii)=Hb;
end

for ii=1:npch %ciclo CHIEF
    Hb=0;Gb=0;
    [Gb,Hb]=integoff(xch(ii),ych(ii),x0,y0,x1,y1,K,2); %16 para pistones, 2 para esfera
    G(npb+ii,:)=Gb;
    H(npb+ii,:)=Hb;
end

%el CHIEF puedes añadir puntos en la geometría para evitar divergencias
gi=V;
gi=-1i*rho*omega*G*gi;
X=H\gi;
clear G H;
numero_onda = 2*pi*freq;
c = real(omega/K);
lambda = c/freq;
tam_geometria_x = max(xm) - min(xm);
tam_geometria_y = max(ym) - min(ym);
tam_geometria = max(tam_geometria_x, tam_geometria_y);   
offset_corregido = max(1.5*tam_geometria, 0.3);
dx_campo = min(max(lambda/20, 0.0005), tam_geometria/10);

[rx,ry] = meshgrid(min(xm)-offset_corregido:dx_campo:max(xm)+offset_corregido,min(ym)-offset_corregido:dx_campo:max(ym)+offset_corregido);

rx=reshape(rx,numel(rx),1);
ry=reshape(ry,numel(ry),1);
if interior
    if numero == 4
        dx_campo = 0.05;
        dy_campo = 0.05;
    else
        dx_campo = 0.0005;
        dy_campo = 0.005;
    end
    % Sin offset, solo dentro de la caja ajustada de la geometría
    
    [rx,ry] = meshgrid(min(xm) : dx_campo : max(xm), ...
                       min(ym) : dy_campo : max(ym));
    rx = reshape(rx, numel(rx), 1);
    ry = reshape(ry, numel(ry), 1);
    

end
end