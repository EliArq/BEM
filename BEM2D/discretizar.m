%Script donde se discretiza la geometría anterior
%se cogen dos puntos consecutivos y se construye un array de N puntos
%equiespaciados, con dimensiones de mínimo 4 elementos
%se obtiene la velocidad en toda la geometría
function [x0,x1,y0,y1,xm,ym,V]=discretizar(bx,by,velocs,dim_el)
nb=numel(bx)-1;
ni=0;
for ii=1:nb
    %Encontramos puntos medios, longitudes de elementos 
    %y sus vectores normales unitarios
    %Con bx,by calculamos x0p,x1p,y0p,y1p, d y numel
    bc=velocs(ii);  %Extraemos valor de velocs
    x0p=bx(ii);     %Extraemos valor de bx
    x1p=bx(ii+1);   %Extraemos valor de bx+1
    y0p=by(ii);     %Extraemos valor de by
    y1p=by(ii+1);   %Extraemos valor de by+1
    d=sqrt((x1p-x0p)^2+(y1p-y0p)^2); 
    numel_ii=max(4,round(d/dim_el));  %Distancia/Tamaño mínimo elementos de frontera
    for ij=1:numel_ii
        %Calculamos diferenciales de x  e y
        dx=(x1p-x0p)/numel_ii;
        dy=(y1p-y0p)/numel_ii;
        ni = ni + 1;
        %Calculamos puntos medios: (XM,YM) entre los puntos del rectangulo
        x0(ni)=x0p+dx*(ij-1);   %El punto del rectangulo mas diferencial por anterior
        x1(ni)=x0p+dx*(ij);     %El punto del rectangulo mas diferencial por actual
        xm(ni)=0.5*(x0(ni)+x1(ni));
        
        y0(ni)=y0p+dy*(ij-1);
        y1(ni)=y0p+dy*(ij);
        ym(ni)=0.5*(y0(ni)+y1(ni));

        V(ni)=bc;   %Vectores normales a cada elemento
    end
end

V=reshape(V,numel(V),1);
return