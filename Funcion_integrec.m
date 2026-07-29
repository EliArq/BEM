%obtencion de la presión en el eje acústico, perpendicular al elemento
%radiante

function [p]=Funcion_integrec(numero,rx,ry,x0,y0,x1,y1,K,X,V,rho,omega)

nrec=numel(rx);
p=zeros(nrec,1);
for ii=1:nrec
    xr=rx(ii);
    yr=ry(ii);
    [Gb,Hb]=integoff(xr,yr,x0,y0,x1,y1,K,6);
    p(ii)=p(ii)-Hb*X-1i*rho*omega*Gb*V; 
end

end
    
