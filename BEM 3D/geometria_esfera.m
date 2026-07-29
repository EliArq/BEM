function [X,Y,Z,v,elementos,nodos,areas,normales] = geometria_esfera(a, rho, w, ntheta, nphi,mostrar_grafico)
Resf = a;
% 1. Coordenadas esféricas
theta = linspace(0, pi, ntheta+1);
phi   = linspace(0, 2*pi, nphi+1);
[Theta, Phi] = meshgrid(theta, phi);
% 2. Coordenadas cartesianas
X = Resf * sin(Theta) .* cos(Phi);
Y = Resf * sin(Theta) .* sin(Phi);
Z = Resf * cos(Theta);

% 3. Vector de nodos (todos los puntos)
nodos = [X(:), Y(:), Z(:)];

% 4. Construir elementos (cuadriláteros)
elementos = [];
areas = [];
normales = [];

for i = 1:nphi
    for j = 1:ntheta
        % Índices de los 4 nodos (en orden antihorario)
        n1 = (i-1)*(ntheta+1) + j;
        n2 = (i-1)*(ntheta+1) + (j+1);
        n3 = i*(ntheta+1) + (j+1);
        n4 = i*(ntheta+1) + j;
        elementos = [elementos; n1, n2, n3, n4];

        % Centro del elemento (para calcular normal y área)
        centro = (nodos(n1,:) + nodos(n2,:) + nodos(n3,:) + nodos(n4,:)) / 4;
        normal = centro / norm(centro); % normal exterior unitaria

        % Área del cuadrilátero (aproximada mediante dos triángulos)
        v1 = nodos(n2,:) - nodos(n1,:);
        v2 = nodos(n3,:) - nodos(n1,:);
        v3 = nodos(n4,:) - nodos(n1,:);
        area = 0.5 * (norm(cross(v1, v2)) + norm(cross(v2, v3)));
        areas = [areas; area];
        normales = [normales; normal];
    end
end

% 5. Condición de contorno: velocidad normal constante (pulsación)
v0 = 1; % amplitud de velocidad

v = 1i * w * rho * v0 * ones(size(elementos,1), 1); 
if mostrar_grafico
    figure;
    trisurf(elementos, X, Y, Z, 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    axis equal; grid on; xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Malla de esfera (3D)');
    view(3);
end
end