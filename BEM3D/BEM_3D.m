%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Programa BEM para analisis de problemas exteriores 3D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all; close all;
c = 345;    % Velocidad del sonido
rho = 1.22; % Densidad del medio
deltaf = 1;
damp = -0.01 * deltaf * 2 * pi * 1i;
[Lx,Ly,Lz] = deal(0.3,0.3,0.3);
a = 0.04;
theta = linspace(0,1.*pi,36);
ntheta = numel(theta);
phi = linspace(0,2.*pi,72);
nphi = numel(phi);
geometria = input('Caja: c, Esfera: e ','s');
n = 5;
if geometria == 'c'
    %% 1. Calculo de frecuencias de resonancia y que cumplen condicion de difraccion
    fprintf('=========================================================\n');
    fprintf('   SUGERENCIAS PARA EL ANALISIS DE DIFRACCION (Ka)\n');
    fprintf('=========================================================\n');
    for i = 1:n
        f_ka_entero = (i * c) / (2 * pi * a);
        f_nulo_difrac = (i * c) / (2 * a); % Ocurre cuando Ka = i*pi
        fprintf('Para Ka = %d exacto       -> Frecuencia: %8.2f Hz\n', i, f_ka_entero);
        fprintf('Para Nulo Difraccion %d   -> Frecuencia: %8.2f Hz (Ka = %1.2f)\n', i, f_nulo_difrac, i*pi);
    end
    
end
if geometria == 'e'
    Resfera = 1;
    a = Resfera;
    fprintf('=========================================================\n');
    fprintf('   SUGERENCIAS PARA EL ANALISIS DE DIFRACCION (Ka)\n');
    fprintf('=========================================================\n');
    for i = 1:n
        f_ka_entero = (i * c) / (2 * pi * Resfera);
        f_nulo_difrac = (i * c) / (2 * Resfera); % Ocurre cuando Ka = i*pi
        fprintf('Para Ka = %d exacto       -> Frecuencia: %8.2f Hz\n', i, f_ka_entero);
        fprintf('Para Nulo Difraccion %d   -> Frecuencia: %8.2f Hz (Ka = %1.2f)\n', i, f_nulo_difrac, i*pi);
    end
end
%% 3. Entrada del usuario y mallado
freq = input('Elige la frecuencia de simulacion (Hz): ');
lambda = c / freq;
fprintf('valor de lambda %10.2f m \n',lambda)
% Criterio estricto: al menos 6 elementos por longitud de onda (lambda/6)
% Limitado a un maximo de 0.015m para no perder definicion geometrica en bajas frecuencias.
dim_el = min(0.015, lambda / 6);
%% 1. Eleccion de tipo de geometria problema
omega = 2 * pi * freq;
w = omega + damp;
K = w / c;
if geometria == 'c'
    [X,Y,Z,v,elementos, nodos,areas,normales,indices_piston,indices_piston_ext,npoints,centro] = geometria_caja(a,Lx,Ly,Lz,rho,w,true);
else
    [X,Y,Z,v,elementos,nodos,areas,normales] = geometria_esfera(Resfera,rho,w,ntheta,nphi,true);
end
Xint = flip(X);
Yint = flip(Y);
Zint = flip(Z);
velocsint = flip(v);
% justo despues de generar la malla, antes del BEM
%producto_radial = sum(normales .* (centro - mean(centro)), 2);
%fprintf('Normales apuntando hacia afuera: %d de %d\n', sum(producto_radial > 0), numel(producto_radial));
%% --- 5. CONTINUACION DEL CALCULO ACUSTICO ---
Resf = max(3*Lx,1);  
fprintf('R que se considera %10.2f m \n',Resf)
%% --- 6. CONSTRUCCION DE MATRIZ BEM Y RESOLUCION ---
interior = false;
[P,rx,ry,rz,p_tot] = EcuacionesFronteraBEM_Green(interior,X,Y,Z,K,v,rho,omega,nodos,elementos,areas,normales,Resf,ntheta,nphi);
interior = true;
[Pint,rxint,ryint,rzint,p_tot_int] = EcuacionesFronteraBEM_Green(interior,Xint,Yint,Zint,K,velocsint,rho,omega,nodos,elementos,areas,normales,Resf,ntheta,nphi);
fprintf('Sistema resuelto.\n');
disp('Funcion integrec completada. \n')


fprintf('Calculo metodo BEM utilizando %i elementos \n', numel(X));
fprintf('Iniciando calculo metodo BEM\n');
fprintf('La frecuencia es = %10.1f Hz \n', freq);

graf = 1; interior=false;
Entornografico(graf,interior,X,Y,Z,v,elementos,nodos)

% Obtencion de la presion sonora
graf = 2; interior = false;
Entornografico(graf,interior,P,X,Y,Z,v,elementos,nodos,p_tot,omega,rx,ry,rz,theta,phi); % Externa
interior = true;
Entornografico(graf,interior,Pint,Xint,Yint,Zint,velocsint,elementos,nodos,p_tot_int,omega,rxint,ryint,rzint,theta,phi); % Interna

%% --- 8. REPRESENTACION DE RADIACION (DIRECTIVIDAD) ---

graf = 3; interior = false;
Entornografico(graf,interior,geometria,P,K,X,Y,Z,v,omega,rho,p_tot,rx,ry,rz,a,nodos,elementos,areas,normales,Resf,theta,phi); % Directividad ext
interior = true;
Entornografico(graf,interior,geometria,Pint,K,Xint,Yint,Zint,velocsint,omega,rho,p_tot_int,rxint,ryint,rzint,a,nodos,elementos,areas,normales,Resf,theta,phi); % Directividad int

%% Calculo de impedancia mecanica y acustica a partir de un barrido de frecuencias
%El tiempo de ejecucion puede ser largo y pesado

ka_vector = logspace(-1, log10(5), 13);
%ka_vector = [];
Z_a_vals = zeros(length(ka_vector), 1);
Z_m_vals = zeros(length(ka_vector), 1);
freq_vals = zeros(length(ka_vector), 1);
eta = 0.025;
for i = 1:length(ka_vector)
    ka = ka_vector(i);
    freq = (ka * c) / (2 * pi * a);
    freq_vals(i) = freq;
    omega = 2 * pi * freq;
    damp = -1i * eta * omega;
    w_i = omega + damp;
    K = (omega / c) * (1 - 1i*eta);
    lambda_i = c/freq;
    if geometria == 'e'
        [X,Y,Z,~,elementos,nodos,areas,normales] = geometria_esfera(Resfera,rho,2*pi*freq,ntheta,nphi,false);
        fprintf('Iteracion %d/%d: ka = %.3f, f = %.1f Hz\n', i, length(ka_vector), ka, freq);
        %S = 4* pi * a^2;
        v0 = 1;
        v_actual = 1i * omega * rho * v0 * ones(size(elementos,1), 1);
    else
        [X,Y,Z,v_actual,elementos,nodos,areas,normales,indices_piston,indices_piston_ext,npoints,~] = geometria_caja(a,Lx,Ly,Lz,rho,omega,false);
        fprintf('Iteracion %d/%d: ka = %.3f, f = %.1f Hz\n', i, length(ka_vector), ka, freq);
        
    end
    % 2. Resolver BEM (exterior)
    interior = false;
    Resf = max(5*a, 5);  % radio de campo lejano
    [P, rx, ry, rz, p_tot] = EcuacionesFronteraBEM_Green(interior, X, Y, Z, K, v_actual, rho, omega, nodos, elementos, areas, normales, Resf,ntheta,nphi);
    
    % 3. Llamar a Entornografico con graf=5 para obtener impedancia (sin dibujar)
    %[Z_a, Z_m, ~, ~] = Entornografico(5, interior, P, K, X, Y, Z, v_actual, omega, rho, p_tot, rx, ry, rz, a, nodos, elementos, areas, normales, Resf, [], []);
    % Calcular impedancia directamente
    if geometria == 'c'
        p_promedio = sum(P(indices_piston_ext) .* areas(indices_piston_ext)) / sum(areas(indices_piston_ext));
        S = sum(areas(indices_piston_ext));   % area correspondiente a la misma region
    else
        p_promedio = sum(P .* areas) / sum(areas);
        S = sum(areas);
    end
    v0 = 1;
    Z_a = p_promedio / v0;
    %fprintf('ka=%.3f | npoints=%d | n_piston_ext=%d | S=%.6f\n', ka, npoints, numel(indices_piston_ext), S);
    Z_m = Z_a * S;
    % Impedancia mecanica (Fuerza / velocidad)
    % Guardar
    Z_a_vals(i) = Z_a;
    Z_m_vals(i) = Z_m;
end

figure('Name', 'Impedancia de radiacion (BEM 3D)');

subplot(1,2,1);
semilogx(ka_vector, real(Z_a_vals)/rho/c, 'b-o', 'LineWidth', 1.5); hold on;
semilogx(ka_vector, imag(Z_a_vals)/rho/c, 'r-s', 'LineWidth', 1.5);
grid on; xlabel('ka'); ylabel('Z_a / \rho c');
legend({'R_a', 'X_a', 'Location'},'FontSize',14);
title('Impedancia acustica','FontSize',16);

% Impedancia mecanica
subplot(1,2,2);
%S = 4*pi*a^2;
semilogx(ka_vector, real(Z_m_vals)/(rho*c*S), 'b-o', 'LineWidth', 1.5); hold on;
semilogx(ka_vector, imag(Z_m_vals)/(rho*c*S), 'r-s', 'LineWidth', 1.5);
grid on; xlabel('ka'); ylabel('Z_m / \rho c S');
legend({'R_m', 'X_m', 'Location'},'FontSize',14);
title('Impedancia mecanica','FontSize',16);

sgtitle('BEM 3D - Piston circular');