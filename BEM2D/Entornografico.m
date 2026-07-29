%Graficar los parámetros acústicos
function Entornografico(graf,numero,interior,varargin)
switch graf
    case 1
        bx = varargin{1};
        by = varargin{2};
        xm = varargin{3};
        ym = varargin{4};
        x0 = varargin{5};
        y0 = varargin{6};
        x1 = varargin{7};
        y1 = varargin{8};
        V = varargin{9};
        velocs = varargin{10};
        figure;
        findv = find(velocs~=0);
        h1 = plot(bx,by, 'r*');
        hold on
        h2 = [];
        for i = findv'
            h2 = plot([bx(i), bx(i+1)], [by(i), by(i+1)], 'k-', 'LineWidth', 2);
            %añadido dibujar vectores normales semiesfera
            %dx = bx(i+1)-bx(i);
            %dy = by(i+1)-by(i);
            %{
            % if dx >= 0
                nx(i) = 0.5*dy;
                ny(i) = 0.5*dx;
            else
                nx(i) = 0.5*dy;
                ny(i) = -0.5*dx;
            end
            if i == numel(findv')
                nx(i) = -nx(i-1);
                ny(i) = ny(i-1);
            end
            %hold on
            %h5 = plot([bx(i+1),bx(i+1)+nx(i)],[by(i+1),by(i+1)+ny(i)],'Linestyle','--','Marker','^');
            %}

        end
        h3 = plot(xm,ym,'y');
        title('Geometria con los puntos definidos');
        grid on;
        xlim ([min(bx)-0.5 max(bx)+0.5])
        ylim ([min(by)-0.5 max(by)+0.5])
        
        %Cambios en leyenda
        if ~isempty(h2)
            legend([h1, h2, h3], {'Geometria puntos originales','Pistón','Geometria discretizada'})
            %legend([h1, h2, h3,h4,h5], {'Geometria puntos originales','Pistón','Geometria discretizada','C','Vectores normales a C'})
        else
            legend([h1, h3], {'Geometria puntos originales','Geometria discretizada'})
        end
        hold off;

        figure;
        plot(bx,by, '-g');
        hold on
        for i = findv'
            plot([bx(i), bx(i+1)], [by(i), by(i+1)], 'k-', 'LineWidth', 2);
        end
        legend({'Geometría','Pistón'}, 'FontSize',14)
        xlim ([min(bx)-0.5 max(bx)+0.5])
        ylim ([min(by)-0.5 max(by)+0.5])
        title('Esquema de la geometría','FontSize',16)
        hold off;

        figure;
        subplot(2,1,2)
        plot(x1,y1)
        title('x1 vs y1')
        xlim ([min(bx)-0.5 max(bx)+0.5])
        ylim ([min(by)-0.5 max(by)+0.5])
        grid on;
        
        figure;
        subplot(1,2,1)
        plot(xm,ym)
        xlim ([min(bx)-0.5 max(bx)+0.5])
        ylim ([min(by)-0.5 max(by)+0.5])
        title('xm vs ym')
        grid on;
        subplot(1,2,2)
        plot(V)
        title('V')
        grid on;
    case 2
        ref_p_dB=2e-5;
        
        switch interior
            case false
            rx = varargin{1};
            ry = varargin{2};
            bx = varargin{3};
            by = varargin{4};
            xm = varargin{5};
            ym = varargin{6};
            X = varargin{7};
            p = varargin{8};
            omega=varargin{9};
            [in,on] = inpolygon(rx,ry,bx,by);
            
            p(in)=NaN;
            rx=[rx; xm.']; 
            ry=[ry; ym.'];
            p=[p; X];
            figure;
            plot(bx,by) 
            hold on;
            plot(rx(in&~on),ry(in&~on),'r+') 
            plot(rx(on),ry(on),'k*')
            plot(rx(~in),ry(~in),'bo') 
            legend('Poligono','Puntos dentro','Puntos borde','Puntos fuera')
            hold off;
            axis tight;
            figure;
                            
            tri=delaunay(rx,ry);
            xc = (rx(tri(:,1)) + rx(tri(:,2)) + rx(tri(:,3))) / 3;
            yc = (ry(tri(:,1)) + ry(tri(:,2)) + ry(tri(:,3))) / 3;
            [in_tri, on_tri] = inpolygon(xc, yc, bx, by);
            tri(in_tri & ~on_tri, :) = [];
            [in_tri, on_tri] = inpolygon(xc, yc, bx, by);
            
            
            trisurf(tri,rx,ry,20*log10(abs(p)/ref_p_dB));
            shading interp
            set(gcf,'renderer','zbuffer')
            view([0 90]);
            hold on;
            plot(bx,by,'-k',xm,ym,'.k');
            hold on;
            axis tight;
            xlabel('x(m)');
            ylabel('y(m)');
            colorbar
            title('Distribución SPL externa (dB)','FontSize',16);
            hold on;
            figure;
            arg=exp(1i*omega);
            trisurf(tri, rx, ry, real(p*arg)); 
            shading interp; view([0 90]);
            set(gcf,'renderer','zbuffer')
            xlabel('x(m)'); ylabel('y(m)'); colorbar;
            title('Presión instantánea (dB) - exterior','FontSize',16);
            hold on;
            axis tight;
            plot(bx, by, '-k', xm, ym, '.k');
            hold on;
            case true
                rxint = varargin{1};
                ryint = varargin{2};
                bxint = varargin{3};
                byint = varargin{4};
                xmint = varargin{5};
                ymint = varargin{6};
                Xint = varargin{7};
                p_int = varargin{8};
                omega = varargin{9};
                [nni,nno]=inpolygon(rxint,ryint,bxint,byint);
                rxint = rxint(nni);
                ryint = ryint(nni);
                p_int = p_int(nni);
                figure;
                triint = delaunay(rxint,ryint);
                trisurf(triint,rxint,ryint,20*log10(abs(p_int)/ref_p_dB));
                shading interp
                set(gcf,'renderer','zbuffer')
                view([0 90]);
                hold on;
                plot(bxint,byint,'-k',xmint,ymint,'.k');
                hold on;
                axis tight;
                xlabel('x(m)');
                ylabel('y(m)');
                colorbar
                title('Distribución SPL interna (dB)','FontSize',16); 
                hold on;
                figure;
                arg=exp(1i*omega);
                trisurf(triint, rxint, ryint, real(p_int*arg));  
                shading interp; view([0 90]);
                set(gcf,'renderer','zbuffer')
                xlabel('x(m)'); ylabel('y(m)'); colorbar;
                title('Presión instantánea (dB) - interior','FontSize',16);
                axis tight;
                hold on;
                plot(bxint, byint, '-k', xmint, ymint, '.k');
                hold on;
        end
        
    case 3
        if numero == 1 
            theta = -pi/2 : 0.01 : pi/2;
        else
            theta=0:0.01:2*pi;
        end
        switch interior
            case false
                R = varargin{1};
                x0 = varargin{2};
                y0 = varargin{3};
                x1 = varargin{4};
                y1 = varargin{5};
                K_original = varargin{6};
                X = varargin{7};
                V = varargin{8};
                omega = varargin{9};
                rho = varargin{10};
                p = varargin{11};
                bx = varargin{12};
                by = varargin{13};
                velocs = varargin{14};
                mostrar_grafico = true;
                xm = (x0+x1)/2;
                ym = (y0+y1)/2;
                a = (max(y1(V~=0)) - min(y0(V~=0))) / 2;
                
                % --- 1. Definición del rango de frecuencias (ka) ---
                ka_vector = [linspace(0.1, 2.9, 6), linspace(3.1, 6, 6)];
                %ka_vector = [];
                %cambiar a 6 para poder estudiar la impedancia
                Z_a_real = zeros(size(ka_vector));
                Z_a_im = zeros(size(ka_vector));
                Z_m_real = zeros(size(ka_vector));
                Z_m_im = zeros(size(ka_vector));
                Z_a_abs = zeros(size(ka_vector));
                freq_vector = zeros(size(ka_vector));
                spl = zeros(size(ka_vector));
                c = omega/K_original;
                pref = 20e-6;
                eta = 1e-5;
                % --- ARREGLO DE LAS GRÁFICAS: Pasamos FALSE en el bucle ---
                for i = 1:length(ka_vector)  
                    Ki = ka_vector(i) / a;
                    omegai = Ki * c;
                    freqi = omegai / (2*pi);
                    freq_vector(i) = freqi;
                    lambda_i = c / freqi;
                    elementos_por_lambda_deseado = 6;
                    dim_el_i = lambda_i / elementos_por_lambda_deseado;
                    % Recalcular la malla para ESTA frecuencia
                    [x0_i,x1_i,y0_i,y1_i,xm_i,ym_i,V_i] = discretizar(bx,by,velocs,dim_el_i);
                    dS_i = sqrt((x1_i-x0_i).^2 + (y1_i-y0_i).^2);
                    Ki_damped = Ki * (1 - 1i*eta);
                    [X_i, ~, ~] = EcuacionesFronteraBEM_KANSA(xm_i, ym_i, x0_i, y0_i, x1_i, y1_i, Ki_damped, V_i, rho, omegai, interior, numero, freqi);
                    % 2. Seleccionar elementos del pistón (donde V != 0)
                    idx_piston = find(V_i ~= 0);
                    p_piston = X_i(idx_piston);    
                    v_piston = V_i(idx_piston);      
                    dS_piston = dS_i(idx_piston);    
                    S_piston = sum(dS_piston);
                    numerador = sum(p_piston .* dS_piston);
                    denominador = sum(v_piston .* dS_piston);
                    if denominador <1e-10
                        continue
                    else    
                        Z_a = numerador / denominador;   % impedancia compleja (real + imaginaria)
                    end
                    numerador_m = sum(p_piston .*S_piston .* dS_piston);
                    Z_m = numerador_m/denominador;
                    Z_m_real(i) = real(Z_m);
                    Z_m_im(i) = imag(Z_m);
                    Z_a_real(i) = real(Z_a);
                    Z_a_im(i) = imag(Z_a);
                    Z_a_abs(i) = abs(Z_a);
                    [~, theta, p] = CalculoDirectividad(numero, theta, R, x0_i, y0_i, x1_i, y1_i, Ki_damped, X_i, V_i, omegai, rho, interior, false);
                    %[~, theta, p] = CalculoDirectividad(numero, theta, R, x0, y0, x1, y1, Ki, X_i, V, omegai, rho, interior, false);
                    [~, idx_eje] = min(abs(theta));   % encuentra el ángulo más cercano a 0
                    p_eje = p(idx_eje);               % presión compleja en el eje
                    p_rms_eje = abs(p_eje) / sqrt(2);
                    spl(i) = 20 * log10(p_rms_eje / pref);
                end
                K = K_original;
                if mostrar_grafico == true
                    if numero == 3      
                        [directividad_BEM] = CalculoDirectividad(numero, theta, R, x0, y0, x1, y1, K, X, V, omega, rho, interior, true);
                    else
                        [directividad_BEM, theta, p] = CalculoDirectividad(numero, theta, R, x0, y0, x1, y1, K, X, V, omega, rho, interior, true);
                    end
                end
                if ~isempty(ka_vector)
                    Entornografico(5,numero,interior,Z_a_real,Z_a_im,Z_m_real, Z_m_im,freq_vector,spl,rho,c)
                end
            case true
                R = varargin{1};
                x0int = varargin{2};
                y0int = varargin{3};
                x1int = varargin{4};
                y1int = varargin{5};
                K = varargin{6};
                Xint = varargin{7};
                Vint = varargin{8};
                omega = varargin{9};
                rho = varargin{10};
                mostrar_grafico = true;
                [directividad_BEM, theta, p] = CalculoDirectividad(numero,theta,R,x0int,y0int,x1int,y1int,K,Xint,Vint,omega,rho,interior, mostrar_grafico);
        end
    case 4
        w = varargin{1};
        freq = varargin{5};
        p = varargin{2};
        rx = varargin{3};
        ry = varargin{4};
        nframes = 4;            
        T = 1/freq;
        tri = delaunay(rx, ry);
        
        figure;
        for k = 1:nframes
            subplot(2,2,k);
            t = T/k;
            p_inst = real(p .* exp(1i * w * t));
            trisurf(tri, rx, ry, zeros(size(rx)), p_inst);
            view(2);               
            axis equal;
            xlabel('x (m)'); ylabel('y (m)');
            colorbar;
            colormap(jet);
            title(sprintf('t = %.2f T', (k-1)/4));
        end
        sgtitle(sprintf('Propagación de la presión - f = %.1f Hz', freq));

    case 5
        %spl_real,spl_im,il_real,il_im)
        Z_A_real = varargin{1};
        Z_A_im = varargin{2};
        Z_m_real = varargin{3};
        Z_m_im = varargin{4};
        freq_vector = varargin{5};
        spl = varargin{6};
        rho = varargin{7};
        c = varargin{8};
        f0 = freq_vector(1);
        spl0 = spl(1);
        f_line = logspace(log10(min(freq_vector)), log10(max(freq_vector)), 100);
        spl_line = spl0 + 6 * log2(f_line / f0);

        figure;
        semilogx(freq_vector, Z_A_real/(rho*c), '--','LineWidth',2)
        hold on
        semilogx(freq_vector, Z_A_im/(rho*c), '--','LineWidth',2)
        grid on
        xlabel('Frecuencia (Hz)')
        ylabel('Z_A (N s/m^5)')
        legend({'Z_A real','Z_A imagiaria'},'FontSize',14,location="best")
        title('Impedancia acústica de radiación','FontSize',16)
        hold off;

        figure;
        semilogx(freq_vector, Z_m_real/(rho*c), '--','LineWidth',2)
        hold on
        semilogx(freq_vector, Z_m_im/(rho*c), '--','LineWidth',2)
        grid on
        xlabel('Frecuencia (Hz)')
        ylabel('Z_m (N s/m^5)')
        legend({'Z_m real','Z_m imag'},'FontSize',14,location="best")
        title('Impedancia mecánica de radiación','FontSize',16)
        hold off;

        figure;
        semilogx(freq_vector, spl)
        hold on
        xlabel('Frecuencias (Hz)')
        xscale('log')
        ylabel('SPL (dB)')
        title('Potencia sonora respecto frecuencias','FontSize',16)
        hold on;
        semilogx(f_line, spl_line, 'r--', 'LineWidth', 1.5);
        hold off;
        legend('SPL','Referencia +6 dB/octava', 'Location', 'best');


end
return