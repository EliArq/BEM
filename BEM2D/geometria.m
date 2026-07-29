%   Funcion para determinar la geometria
%Es posible elegir entre diferentes geometrías: pistón con pantalla
%infinita, pistón libre, polígono, cilindro infinito, bass reflex
% Se construye en sentido antihorario (exterior) u horario (interior), y se
% toma el último punto como el primero
%velocidad de módulo 1 para la superficie vibrante
function [bx,by,velocs]=geometria(geometria_elegida,varargin) 

switch geometria_elegida
    case 1 %Pistón + pantalla infinita
        Ly_pis = 0.02;
        fprintf('Longitud del pistón: %10.2f \n',Ly_pis);
        Ly_pan = input('Longitud de la pantalla ');
        bx = [0                   0.0216             0.0216      0.0216        0.0216           0               0];
        by = [-Ly_pan-Ly_pis/2,  -Ly_pan-Ly_pis/2,  -Ly_pis/2,   Ly_pis/2,   Ly_pan+Ly_pis/2,  Ly_pan+Ly_pis/2,  -Ly_pan-Ly_pis/2];
        velocs = zeros(length(by)-1,1);
        velocs(3) =1;

    case 2 %Pistón libre
        Ly_pis = 0.02;
        fprintf('Longitud del pistón: %10.2f \n',Ly_pis);
        Ly_pan = input('Longitud de la pantalla ');
        
        bx = [0.0216,              0.0216,           0.0216,        0.0216,           0,                 0,               0,              0                 0.0216];
        by = [-Ly_pan-Ly_pis/2,   -Ly_pis/2,         Ly_pis/2,      Ly_pan+Ly_pis/2,  Ly_pan+Ly_pis/2,   Ly_pis/2,        -Ly_pis/2,      -Ly_pan-Ly_pis/2  -Ly_pan-Ly_pis/2];
        velocs = zeros(length(by)-1,1);
        velocs(2) = 1;   
        velocs(6) = -1; 

    case 3 %Polígono: rectángulo-cuadrado
        fprintf('Cuadrado lx = ly \n');
        a = input('Elige lx: ');
        h = a;
        bx = [0  a/3 2*a/3  a    a      a      a  2*a/3 a/3   0  0     0   0];
        by = [0  0   0      0    h/3    2*h/3  h    h   h     h  2*h/3 h/3 0];
        velocs = zeros(length(bx)-1,1);
        velocs(11)=1;
 
    case 4 %esfera pulsante r = 1
        N = 50;
        a = 1;
        theta = linspace(0,2*pi,N);
        bx = a*cos(theta);
        by = a*sin(theta);
        bx = [bx(:); bx(1)];  
        by = [by(:); by(1)];
        velocs = ones(length(by)-1,1);

    case 5 %Bass-reflex
        fprintf('Cuadrado lx = ly \n');
        a = input('Elige lx: ');
        h = a;
        bx = [0  a/4 a/2  3*a/4    a   a      a       a     a    3*a/4  a/2   a/4     0      0      0      0     0];
        by = [0  0   0      0      0   h/4    h/2    3*h/4  h    h      h     h       h      3*h/4  h/2   h/4   0];
        velocs = zeros(length(bx)-1,1);
        velocs(13)=1;
        velocs(16)=1;
        
end
return