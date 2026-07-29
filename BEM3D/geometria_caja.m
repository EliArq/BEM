function [X,Y,Z,v,elementos, nodos,areas,normales,indices_piston,indices_piston_ext,npoints,centro] = geometria_caja(a,Lx,Ly,Lz,rho,w,mostrar_grafico)
freq = w / (2*pi);
lambda = 345 / freq;

elementos_por_lambda_deseado = 8;
npoints_min = 25;
npoints_max = 35;

npoints = min(npoints_max, max(npoints_min, ceil(elementos_por_lambda_deseado * Lx / lambda) + 1));

%1a cara plano (x,0,0)
x = linspace(0,Lx,npoints);
y = linspace(0,Ly,npoints);
z = linspace(0,Lz,npoints);

X = [];
Y = [];
Z = [];
nodos = [];
elementos = [];
radio_pis = a;
areas = [];
normales = [];

%PLANO X=0
[Y1,Z1] = meshgrid(y,z);

X1 = zeros(size(Z1));
X = [X;X1(:)];
Y = [Y;Y1(:)];
Z = [Z;Z1(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X1, Y1, Z1); 


%PLANO Y = 1
[X2,Z2] = meshgrid(x,z);
Y2 = Ly*ones(size(Z2));
X = [X;X2(:)];
Y = [Y;Y2(:)];
Z = [Z;Z2(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X2, Y2, Z2);



%PLANO X = 1
[Y3,Z3]=meshgrid(y,z);
X3 = Lx*ones(size(Y3));
X = [X;X3(:)];
Y = [Y;Y3(:)];
Z = [Z;Z3(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X3, Y3, Z3); 



%PLANO Y = 0
[X4,Z4]=meshgrid(x,z);
Y4 = zeros(size(X4));
X = [X;X4(:)];
Y = [Y;Y4(:)];
Z = [Z;Z4(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X4, Y4, Z4);


%PLANO Z = 0
[X5,Y5] = meshgrid(x,y);
Z5 = zeros(size(X5));
X = [X;X5(:)];
Y = [Y;Y5(:)];
Z = [Z;Z5(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X5, Y5, Z5); 

%PLANO Z = Lz
[X6,Y6] = meshgrid(x,y);
Z6 = Lz*ones(size(X6));
X = [X;X6(:)];
Y = [Y;Y6(:)];
Z = [Z;Z6(:)];
[nodos, elementos, areas, normales] = addFace(nodos, elementos,areas,normales, X6, Y6, Z6); 

%plot3(X,Y,Z)

function [nodos, elementos, areas,normales] = addFace(nodos, elementos,areas,normales, X, Y, Z)
    base = size(nodos, 1);
    n = size(X, 1);
    % Añadir nodos
    nodos = [nodos; X(:), Y(:), Z(:)];
    % Crear índices lineales para los nodos de esta cara
    idx = reshape(base + (1:numel(X))', size(X));
    for i = 1:n-1
        for j = 1:n-1
            n1 = idx(i, j);
            n2 = idx(i, j+1);
            n3 = idx(i+1, j+1);
            n4 = idx(i+1, j); %diagonales del cuadrado en sentido antihorario
            elementos = [elementos; n1, n2, n3, n4]; 
            v1 = nodos(n2, :) - nodos(n1, :); %base (origen n1)
            v2 = nodos(n4, :) - nodos(n1, :); %altura 
            n_vec = cross(v1, v2); %base*altura
            area = norm(n_vec);
            if area > 1e-12
                normal = n_vec / area;
            else
                normal = [0, 0, 0];
            end
        areas = [areas; area];
        normales = [normales; normal];
        end
    end     
end

centro_caja = [Lx/2, Ly/2, Lz/2];
for ii = 1:size(normales, 1)
    ci = (nodos(elementos(ii,1),:) + nodos(elementos(ii,2),:) + nodos(elementos(ii,3),:) + nodos(elementos(ii,4),:)) / 4;
    % Vector desde el centro de la caja al centro
    vec = ci - centro_caja;
    % Si la normal apunta en dirección opuesta al vector, invertir
    if dot(vec, normales(ii, :)) < 0
        normales(ii, :) = -normales(ii, :);
    end
end

centro = (nodos(elementos(:,1),:) + nodos(elementos(:,2),:) + nodos(elementos(:,3),:) +nodos(elementos(:,4),:)) /4; 
%se cogen todos los centros
centrodez = centro(:,3); %plano Z 
%centrodex = centro(:,1); %plano X
error = 1e-8;
en_Z = abs(centrodez) < error;
%en_X = abs(centrodex) < error;
centrode_cara = centro(en_Z,:);
indices = find(en_Z);
puntomediox = Lx/2;
puntomedioy = Ly/2;
puntomedioz = Lz/2;
%distancia euclídea entre el centro del pistón y el centro de los cuadrados
%que le rodea, en el plano X=0
%dist = sqrt((centrode_cara(:,2) - puntomedioy).^2+(centrode_cara(:,1)-puntomediox).^2);  %centrada
dist = sqrt((centrode_cara(:,1)-puntomediox/2).^2 +(centrode_cara(:,2) - radio_pis).^2); %esquina
%derecha abajo
%dist = sqrt((centrode_cara(:,1)-puntomediox/2).^2 + (centrode_cara(:,2)-puntomedioy).^2);
%lado derecho


piston = find(dist < radio_pis);

indices_piston = indices(piston);
tam_el_local = sqrt(mean(areas(indices)));  % tamaño característico de elemento en esa cara
margen = 1.0 * tam_el_local;                % una capa de elementos de margen (ajustable: 0.5-2x)
piston_ext = find(dist < (radio_pis + margen));
indices_piston_ext = indices(piston_ext);

piston = find(dist < radio_pis);
indices_piston = indices(piston);
v = zeros(size(elementos, 1), 1);
v0 = 1;
v(indices_piston) = 1i*w*rho*v0;

if mostrar_grafico
    figure;
    trisurf(elementos,X,Y,Z)
    hold on
    trisurf(elementos, nodos(:,1), nodos(:,2), nodos(:,3), 'EdgeColor', 'k', 'FaceAlpha', 0.5);
    axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(3);
    hold off
    
    figure;
    trisurf(elementos,X,Y,Z)
    hold on
    trisurf(elementos(indices_piston,:),nodos(:,1), nodos(:,2), nodos(:,3), 'FaceColor', 'r', 'EdgeColor', 'k');
    axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(3);
    
end
end