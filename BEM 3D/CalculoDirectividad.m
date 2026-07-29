function [directividad_BEM_hor,directividad_BEM_vert, theta, phi, p_tot] = CalculoDirectividad(Z,geometria, theta, phi, rx, ry, rz, K, p_tot, v, omega, rho, a, interior, mostrar_grafico)
    

nTheta = numel(theta);
nPhi = numel(phi);
p_mat = reshape(p_tot, nPhi, nTheta);
theta_completo = [-flip(theta), theta(2:end)];


[~, idx_theta_90] = min(abs(theta - pi/2));
p_ecuador = p_mat(:, idx_theta_90); 
[~,idx_phi_0] = min(abs(phi));
p_mer = p_mat(idx_phi_0, :); 
% Normalizamos la presión para obtener la directividad en dB
p_norm_ec = abs(p_ecuador) / max(abs(p_ecuador));
p_norm_mer = abs(p_mer) / max(abs(p_mer));
directividad_dB_ec = 20 * log10(p_norm_ec + 1e-12);
directividad_dB_mer = 20 * log10(p_norm_mer + 1e-12);
directividad_dB_mer_completo = [flip(directividad_dB_mer), directividad_dB_mer(2:end)];
directividad_BEM_hor = directividad_dB_ec;
directividad_BEM_vert = directividad_dB_mer_completo;

% --- DIRECTIVIDAD TEÓRICA ---
if geometria == 'c'
    x = K * a * sin(pi/2) * sin(phi'); 
    D = zeros(size(x));
    D(x == 0) = 1;
    D(x ~= 0) = 2 * besselj(1, x(x ~= 0)) ./ x(x ~= 0);
    x_theta = K * a * sin(theta);
    D_theta = zeros(size(x_theta));
    D_theta(x_theta==0) = 1;
    D_theta(x_theta ~= 0) = 2 * besselj(1, x_theta(x_theta ~=0)) ./ x_theta(x_theta ~=0);
    DdB_theta = 20 * log10(abs(D_theta) + 1e-12);
    DdB = 20 * log10(abs(D) + 1e-12);
    DdB_theta_completo = [flip(DdB_theta), DdB_theta(2:end)];
end
if geometria == 'e'
    D = ones(size(phi'));
    DdB = 20*log10(D);
end
% Devolvemos las variables necesarias corregidas


% --- GRÁFICA POLAR ---
if mostrar_grafico == true
    if geometria == 'c'
        figure;
        polarplot(phi, directividad_dB_ec, 'r-', 'LineWidth', 2);
        hold on;
        polarplot(phi, DdB, 'k--', 'LineWidth', 1.5);
        rlim([-40, 0]);
        thetalim([-90, 90])
        legend({'Directividad BEM (Caja)', 'Teórica (Pistón ideal)'},'FontSize',14);

        hold off;
        figure;
        polarplot(theta_completo, directividad_dB_mer_completo, 'r-', 'LineWidth', 2);
        hold on;
        polarplot(theta_completo, DdB_theta_completo, 'k--', 'LineWidth', 1.5);
        legend({'Directividad BEM (Caja)', 'Teórica (Pistón ideal)'},'FontSize',14);
        hold off;
    else
        polarplot(phi, DdB,'k--','LineWidth',1.5);
        hold on;
        polarplot(phi,directividad_dB_ec, 'r-', 'LineWidth', 2);
        rlim([-40, 0]);
        legend({'Directividad BEM (Esfera)', 'Teórica (Esfera pulsante)'},'FontSize',14);
        hold off;


    end
    if interior == false
        title(sprintf('Directividad en el plano XY (Exterior)'),'FontSize',16);
    else
        title(sprintf('Directividad en el plano XY (Interior)'));
    end
    if interior == false
        title(sprintf('Directividad en el plano Z (Exterior)'), 'FontSize',16);
    else
        title(sprintf('Directividad en el plano Z (Interior)'));
    end
end
end