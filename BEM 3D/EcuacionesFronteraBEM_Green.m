%En este caso las funciones de Green se resuelven analíticamente, y no es
%necesario tomar métodos numéricos.
%El BEM se resuelve tanto en la geometría como en el mallado exterior
function [P,rx,ry,rz,p_tot]=EcuacionesFronteraBEM_Green(interior,X,Y,Z,K,v,rho,omega,nodos,elementos,areas,normales,Resf,ntheta,nphi)
%Inicializamos matrices
centro = (nodos(elementos(:,1),:) + nodos(elementos(:,2),:) + nodos(elementos(:,3),:) + nodos(elementos(:,4),:)) /4;
%disp(size(centro))
npb = size(elementos,1); 
G=zeros(npb,npb);
H=zeros(npb,npb);
for ii=1:npb
    % Cargamos puntos medios
    xp=centro(ii,1);
    yp=centro(ii,2);
    zp=centro(ii,3);
    for jj=1:npb
        x0p=centro(jj,1);%puntos fuente
        y0p=centro(jj,2);
        z0p=centro(jj,3);
        R = sqrt((xp-x0p)^2 + (yp-y0p)^2 + (zp-z0p)^2);
        if R < 1e-6
            Gb = 0.28 * sqrt(areas(jj));
            Hb = 0.0;
        else
            Gb = exp(-1i*K*R)/(4*pi*R)*areas(jj);
            % Derivada normal de G
            % dr/dn = (dx*nx + dy*ny + dz*nz) / R
            drdn = ((x0p-xp) * normales(jj,1) + (y0p-yp) * normales(jj,2) + (z0p-zp) * normales(jj,3)) / R;
            dGdn = -(1 + 1i*K*R) * exp(-1i*K*R) / (4 * pi * R^2) * drdn;
            Hb = dGdn*areas(jj);
        end
        
        G(ii,jj)=Gb;
        H(ii,jj)=Hb;
    end        
end
 
disp('G y H calculadas')
%coordenadas esféricas
Lx = max(X)-min(X);
Ly = max(Y)-min(Y);
Lz = max(Z)-min(Z);
centro_cara = [Lx/2,Ly/2,Lz/2];
theta = linspace(0,pi,ntheta);
phi = linspace(0,2*pi,nphi);
[theta,phi]=meshgrid(theta,phi);
rx = centro_cara(1) + Resf*sin(theta).*cos(phi);
ry = centro_cara(2) + Resf*sin(theta).*sin(phi);
rz = centro_cara(3) + Resf*cos(theta);
rx = rx(:);
ry = ry(:);
rz = rz(:);
nuRe = numel(rx); %numero de receptores
H = H + 0.5 * eye(npb);
p_tot = zeros(nuRe,1);
P = H \ (G * v);
for ii=1:nuRe
    xp1=rx(ii);
    yp1=ry(ii);
    zp1=rz(ii);
    p_local = 0;
    for jj=1:npb
        x0p1=centro(jj,1);%puntos fuente
        y0p1=centro(jj,2);
        z0p1=centro(jj,3);
        R = sqrt((xp1-x0p1)^2 + (yp1-y0p1)^2 +(zp1-z0p1)^2);
        if R < 1e-12
           continue;  % Evitar singularidad (receptor en la superficie)
        end
        Gb = exp(-1i*K*R)/(4*pi*R)*areas(jj);
        drdn = ((x0p1-xp1) * normales(jj,1) + (y0p1-yp1) * normales(jj,2) + (z0p1-zp1) * normales(jj,3)) / R;
        dGdn = -(1 + 1i*K*R) * exp(-1i*K*R) / (4 * pi * R^2) * drdn;
        Hb = dGdn*areas(jj);
        p_local = p_local +Gb*v(jj) - Hb*P(jj);
    end
    p_tot(ii) = p_local;
end

end
