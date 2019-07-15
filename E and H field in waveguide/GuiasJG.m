%Entrada de variáveis
clear;
clc;
f  = input('Digite a frequência de operação [GHz]: ');
f = f*1e9;             %Frequência de operação
a = input('Digite a dimensão "a" do guia (cm): ');
a = a*1e-2;             %Dimensão a do guia 
b = input('Digite a dimensão "b" do guia (cm): ');
b = b*1e-2;             %Dimensão b do guia 
mod = input('Digite o Modo de propagação 1)- TE 2)- TM :');%Modo de propagação
m = input('Digite o índice "m": Ex: TEm:  '); %(TE/TM)mn
n = input('Digite o índice "n": Ex: TEn: ' );%(TE/TM)mn
pass = 50;

if mod == 1
    TE = 1;
    TM = 0;
else
    TE = 0;
    TM = 1;
end

tg = 0.0001;             %Tangente de perdas
er = 1;                  %Permissividade relativa
ur = 1;                  %Permeabilidade relativa
w  = 2*pi*f;             %Frequência angular 
u0 = 4*pi*1e-7;          %Permeabilidade do ar
e0 = 8.8541878176e-12;   %Permissividade do ar
ef = e0*er;              %Permissividade efetiva 
uf = u0*ur;              %Permeabilidade efetiva
%Cálculo das demais variáveis 
c = 1/sqrt(uf*ef);                 %Velocidade da onda no dielétrico
k = w*sqrt(uf*ef);                 %Número de onda global
kc = pi*sqrt((m/a)^2 + (n/b)^2);   %Número de onda de corte       
fc = (c/2)*sqrt((m/a)^2 + (n/b)^2);%Frequência de corte
lambdac = 2*pi/kc;                 %Comprimento de onda de corte
lambda = f/(3*10^10);              %1/lambda para determinar o número de modos






if TE == 1
    [EHz,x,y,z] = TEmn(a,b,m,n,k,1);
else
    [EHz,x,y,z] = TMmn(a,b,m,n,k,1);
end



superior = zeros(pass);
lateral = superior;
frontal = lateral;

if TE == 1
        for jj=1:1:pass
              for kk=1:1:pass
                    frontal(jj,kk) = EHz(kk,jj,pass/2); %Deixando o plano z fixo
                    superior(jj,kk)= EHz(jj,pass/2,kk);%Deixando o plano b fixo
                    lateral(jj,kk) = EHz(pass/2,jj,kk); %Deixando o plano a fixo
                                      
              end            
        end
else
        for jj=1:1:pass
              for kk=1:1:pass
                    frontal(jj,kk) = EHz(kk,jj,pass/2); %Deixando o plano z fixo
                    superior(jj,kk)= EHz(kk,pass/2,jj); %Deixando o plano b fixo
                    lateral(jj,kk) = EHz(pass/2,kk,jj); %Deixando o plano a fixo 
                                      
              end            
        end
end

        subplot(3,1,1)
        [X,Y] = meshgrid(x,y);
        Z = real(frontal);
        contourf(X,Y,Z,15);
        title('Vista frontal');
        set(gca,'xticklabel',{[]});
        set(gca,'yticklabel',{[]});
        xlabel('a');
        ylabel('b');
        

        subplot(3,1,2)
        if TE == 1
        [Z,x,y,z] = TEmn(a,b,m,n,k,2);
        else
        [Z,x,y,z] = TMmn(a,b,m,n,k,2);
        end
        [X,Y] = meshgrid(z,x);
        %Z = real(lateral);
        Z1(:,:) = real(Z(pass/2,:,:));
        contourf(X,Y,Z1,10);
        title('Vista lateral');
        set(gca,'xticklabel',{[]});
        set(gca,'yticklabel',{[]});
        xlabel('z');
        ylabel('b');
        
        
        subplot(3,1,3)
        if TE == 1
        [Z,x,y,z] = TEmn(a,b,m,n,k,2);
        else
        [Z,x,y,z] = TMmn(a,b,m,n,k,2);
        end
        [X,Y] = meshgrid(y,z);
        %Z = real(superior);
        Z1(:,:) = real(Z(:,pass/2,:));
        contourf(X,Y,Z1,10);
        title('Vista superior');
        set(gca,'xticklabel',{[]});
        set(gca,'yticklabel',{[]});
        xlabel('z');
        ylabel('a');
        colormap jet;
               
             
        figure(2)
        plotar(lambda,a,b);
        
        
         

       
        
