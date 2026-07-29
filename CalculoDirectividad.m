%obtencion de la directividad para cada sistema, si existe una solución
%teórica simple del sistema, se hace una comparación con el valor obtenido
%por el BEM
function [directividad_BEM, theta, p]=CalculoDirectividad(numero,theta,R,x0,y0,x1,y1,K,X,V,omega,rho,interior, mostrar_grafico)

a = (max(y1(V~=0)) - min(y0(V~=0))) / 2;
rx=R*cos(theta);
ry=R*sin(theta);
[p]=Funcion_integrec(numero,rx,ry,x0,y0,x1,y1,K,X,V,rho,omega);
z = K * a * sin(theta);
directividad_analitica = ones(size(theta)); 

if numero == 1
    % Evitamos división por cero si z contiene un 0 exacto
    z_safe = z;
    z_safe(z_safe == 0) = 1e-12;
    directividad_analitica = abs(2 * besselj(1, z_safe) ./ (z_safe)); 
end

if numero == 2
    directividad_analitica = abs(sinc(z / pi)) .* abs(cos(theta));
end

if numero == 4
    directividad_analitica = ones(size(theta)); 
end



p_norm = abs(p) / max(abs(p));
directividad_BEM = 20 * log10(p_norm);
analitica_db = 20 * log10(directividad_analitica);

if mostrar_grafico == true
    figure;
    if numero ~= 3 && numero ~= 5
        polarplot(theta, analitica_db, 'b', 'LineWidth', 1.5, 'DisplayName', 'Analítica');
        hold on;
    end
    polarplot(theta, directividad_BEM, 'r--', 'LineWidth', 1.5, 'DisplayName', 'BEM');
    if numero == 1
        thetalim([-90 90]);
    end
    rlim([-40, 0]); 
    legend('Location', 'best','FontSize',14);
    
    if interior == false
        title('Directividad exterior','FontSize',16);
    else
        title('Directividad interior');
    end
    hold off;
end

end