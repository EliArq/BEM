function varargout = Entornografico(graf,interior,varargin)
switch graf
    case 1
        X = varargin{1};
        Y = varargin{2};
        Z = varargin{3};
        v = varargin{4};
        elementos = varargin{5};
        nodos = varargin{6};        
        figure;
        findv = find(v~=0);
        plot3(X,Y,Z, 'r*');
        hold on
        figure;
        trisurf(elementos,X,Y,Z)
        hold on
        title('Geometria de puntos medios');
        grid on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        xlim([min(X(:))-0.05 max(X(:))+0.05])
        ylim([min(Y(:))-0.05 max(Y(:))+0.05])
        zlim([min(Z(:))-0.05 max(Z(:))+0.05])
        figure;
        plot(real(v),imag(v),"o")
        title('V')
        grid on;
    case 2
        ref_p_dB=2e-5;
        switch interior
            case false
                P = varargin{1};
                X = varargin{2};
                Y = varargin{3};
                Z = varargin{4};
                v = varargin{5};
                elementos = varargin{6};
                nodos = varargin{7};
                p_tot = varargin{8};
                omega = varargin{9};
                rx = varargin{10};
                ry = varargin{11};
                rz = varargin{12};
                theta = varargin{13};
                phi = varargin{14};
                ntheta = numel(theta);
                nphi = numel(phi);
                SPL = 20*log10(abs(p_tot)/ref_p_dB);
                figure;
                scatter3(rx, ry, rz,20, SPL, 'filled');
                colormap(jet); colorbar; axis equal; view(3);
                colormap(jet); colorbar; axis equal; view(3);
                title('SPL en esfera de radio 1 m','FontSize',16);
                xlabel('X'); ylabel('Y'); zlabel('Z');
                SPL_lejano = 20*log10(abs(p_tot)/ref_p_dB);
                figure;
                scatter3(rx, ry, rz, 20, SPL_lejano, 'filled');
                colormap(jet); colorbar; axis equal; grid on; view(3);
                title('SPL en campo lejano (exterior)','FontSize',16); xlabel('X'); ylabel('Y'); zlabel('Z');
            case true
                %Pint,Xint,Yint,Zint,velocsint,elementos,nodos,p_tot_int,omega); % Interna
                Pint = varargin{1};
                Xint = varargin{2};
                Yint = varargin{3};
                Zint = varargin{4};
                velocsint = varargin{5};
                elementos = varargin{6};
                nodos = varargin{7};
                p_tot_int = varargin{8};
                omega = varargin{9};
                rxint = varargin{10};
                ryint = varargin{11};
                rzint = varargin{12};
                theta = varargin{13};
                phi = varargin{14};
                SPL = 20*log10(abs(p_tot_int)/ref_p_dB);
                figure;
                scatter3(rxint, ryint, rzint, 20,SPL, 'filled');
                colormap(jet); colorbar; axis equal; view(3);
                xlabel('X'); ylabel('Y'); zlabel('Z');
                title('SPL en esfera de radio 1 m');

        end
        
    case 3
        ref_p_dB=2e-5;
        switch interior
            case false
                %graf,interior,Pint,R,K,Xint,Yint,Zint,velocsint,omega,rho,p_tot_int,rxint,ryint,rzint); % Directividad int
                geometria = varargin{1};
                P = varargin{2};
                K = varargin{3};
                X = varargin{4};
                Y = varargin{5};
                Z = varargin{6};
                v = varargin{7};
                omega = varargin{8};
                rho = varargin{9};
                p_tot = varargin{10};
                rx = varargin{11};
                ry = varargin{12};
                rz = varargin{13};
                a = varargin{14};
                nodos = varargin{15};
                elementos = varargin{16};
                areas=varargin{17};
                normales = varargin{18};
                Resf = varargin{19};
                theta = varargin{20};
                phi = varargin{21};
                SPL = 20*log10(abs(p_tot)/ref_p_dB);
                mostrar_grafico = true;
                pref = 20e-6;
                
                
                if mostrar_grafico == true
                    [~,~, theta, phi,p_tot] = CalculoDirectividad(Z,geometria,theta, phi, rx,ry,rz,K, p_tot, v, omega, rho, a,interior, true);
                end
                
               
                %Entornografico(4,interior,SPL,rho)                
            case true
                geometria = varargin{1};
                Pint = varargin{2};
                K = varargin{3};
                Xint = varargin{4};
                Yint = varargin{5};
                Zint = varargin{6};
                velocsint = varargin{7};
                omega = varargin{8};
                rho = varargin{9};
                p_tot_int = varargin{10};
                rxint = varargin{11};
                ryint = varargin{12};
                rzint = varargin{13};
                a = varargin{14};
                nodos = varargin{15};
                elementos = varargin{16};
                areas=varargin{17};
                normales = varargin{18};
                Resf = varargin{19};
                theta = varargin{20};
                phi = varargin{21};
                mostrar_grafico = true;
                SPL = 20*log10(abs(p_tot_int)/ref_p_dB);
                
                [~,~, theta, phi, p_tot_int] = CalculoDirectividad(Zint,geometria,theta,phi,rxint,ryint,rzint,K,p_tot_int,velocsint,omega,rho,a,interior, mostrar_grafico);
        end

end
return