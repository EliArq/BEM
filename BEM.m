%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Programa BEM para análisis de problemas exteriores
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all; close all;
c = 345;    % Velocidad del sonido
rho = 1.22; % Densidad del medio
deltaf = 1;
damp = -0.0 * deltaf * 2 * pi * 1i;


%% 1. Elección de tipo de geometría problema
disp('Tipos de geometría')
disp('1: Pistón + pantalla infinita')
disp('2: Pistón libre')
disp('3: Caja cerrada')
disp('4: Cilindro infinito')
disp('5: Bass Reflex')
numero = input('Número: ');

[bx,by,velocs] = geometria(numero);
bxint = flip(bx);
byint = flip(by);
velocsint = flip(velocs);

%% 2. Cálculos previos para control del problema
Lx = max(bx) - min(bx); %tamaños de los segmentos para la freq de resonancia
Ly = max(by) - min(by);

% Encontrar el semi-ancho 'a' del pistón buscando los segmentos con velocidad distinta de cero
find_piston = find(velocs ~= 0);
if ~isempty(find_piston)
    y_piston = [];
    for idx = find_piston'
        y_piston = [y_piston, by(idx), by(idx+1)]; % Almacena extremos del segmento móvil
    end
    a = (max(y_piston) - min(y_piston)) / 2;
else
    a = 0.02; % Valor por defecto
end

%% 3. Cálculo de frecuencias de resonancia y que cumplen condición de difracción
n = 20; % Número de órdenes a calcular

fprintf('=========================================================\n');
fprintf('   SUGERENCIAS (Ka)\n');
fprintf('=========================================================\n');
for i = 1:n
    f_ka_entero = (i * c) / (2 * pi * a);
    f_nulo_difrac = (i * c) / (2 * a); % Ocurre cuando Ka = i*pi
    fprintf('Para Ka = %d exacto       -> Frecuencia: %8.2f Hz\n', i, f_ka_entero);
    fprintf('Para Nulo Difracción %d   -> Frecuencia: %8.2f Hz (Ka = %1.2f)\n', i, f_nulo_difrac, i*pi);
end
%Cálculo de frecuencias problemáticas del BEM (descomentar)
%{
fprintf('\n=========================================================\n');
fprintf('   SUGERENCIAS DE FRECUENCIAS MODALES (Cavidad 2D)\n');
fprintf('=========================================================\n');
frec_mod = zeros(n, n); 
for i = 1:n      % nx
    for j = 1:n  % ny
        nx = i; ny = j - 1;
        frec_mod(i,j) = (c / 2) * sqrt((nx / Lx)^2 + (ny / Ly)^2);
        fprintf('Modo (%d,%d) -> Frecuencia: %8.2f Hz\n', nx, ny, frec_mod(i,j));
    end
end
fprintf('=========================================================\n');
%}
%% 4. Entrada del usuario y mallado
freq = input('Elige la frecuencia de simulación (Hz): ');
lambda = c / freq;
fprintf('Valor de lambda %10.2f ',lambda)
% Criterio estricto: al menos 6 elementos por longitud de onda (lambda/6)
% Limitado a un máximo de 0.015m para no perder definición geométrica en bajas frecuencias.
dim_el = min(0.05, lambda / 6);

%% 5. Discretización
[x0,x1,y0,y1,xm,ym,V] = discretizar(bx,by,velocs,dim_el);
[x0int,x1int,y0int,y1int,xmint,ymint,Vint] = discretizar(bxint,byint,velocsint,dim_el);

%% --- 6. CONTINUACIÓN DEL CÁLCULO ACÚSTICO ---
omega = 2 * pi * freq;
a = (max(y1(V~=0)) - min(y0(V~=0))) / 2;  % semilongitud del pistón
pantalla = 10*lambda;
%Calculo R campo lejano
if freq < 1e4
    R = max(12*lambda, 12*(2*a));  
else
    R = max(24*lambda, 24*(2*a));
end
fprintf('Radio de campo lejano (criterio Fraunhofer): R = %.2f m\n', R);
fprintf('Para que cumpla condición de infinito, la pantalla debe medir approx >= %10.2f \n', pantalla);
w = omega + damp;
K = w / c;


%% --- 7. CONSTRUCCIÓN DE MATRIZ BEM Y RESOLUCIÓN ---
interior = false;
[X,rx,ry] = EcuacionesFronteraBEM_KANSA(xm,ym,x0,y0,x1,y1,K,V,rho,omega,interior,numero,freq);
interior = true;
[Xint,rxint,ryint] = EcuacionesFronteraBEM_KANSA(xmint,ymint,x0int,y0int,x1int,y1int,K,Vint,rho,omega,interior,numero,freq);
fprintf('Sistema resuelto.\n');

%% --- 8. CÁLCULO DE PRESIÓN EN RECEPTORES ---
%se obtiene la matriz BEM para todos los puntos del mallado exterior
[p] = Funcion_integrec(numero,rx,ry,x0,y0,x1,y1,K,X,V,rho,omega);
[p_int] = Funcion_integrec(numero,rxint,ryint,x0int,y0int,x1int,y1int,K,Xint,Vint,rho,omega);
disp('Función integrec completada.')

%% Entorno gráfico
interior = false;
figure;
plot(bx,by); hold on; plot(bxint,byint);
xlim ([min(bx)-1 max(bx)+1]); ylim ([min(by)-1 max(by)+1]);
title('Puntos geometría original y puntos interior')
legend('Exterior','Interior'); grid on;

fprintf('Cálculo método BEM utilizando %i elementos \n', numel(xm));
fprintf('Iniciando cálculo método BEM\n');
fprintf('La frecuencia es = %10.1f Hz \n', freq);

graf = 1;
Entornografico(graf,numero,interior,bx,by,xm,ym,x0,y0,x1,y1,V,velocs)


% Obtención de la presión sonora
graf = 2; interior = false;
Entornografico(graf,numero,interior,rx,ry,bx,by,xm,ym,X,p,omega); % Externa
interior = true;
Entornografico(graf,numero,interior,rxint,ryint,bxint,byint,xmint,ymint,Xint,p_int,omega); % Interna

%% --- 9. REPRESENTACIÓN DE RADIACIÓN (DIRECTIVIDAD) ---
graf = 3; interior = false;
Entornografico(graf,numero,interior,R,x0,y0,x1,y1,K,X,V,omega,rho,p,bx,by,velocs); % Directividad ext
interior = true;
Entornografico(graf,numero,interior,R,x0int,y0int,x1int,y1int,K,Xint,Vint,omega,rho,p,bxint,byint,velocsint); % Directividad int

