clear
%ENTRADA DAS IMAGENS 
%IMAGENS "The ORL DATABASE of faces"
profile on

QTD = 10;        %NÚMERO DE IMAGENS A SER ADICIONADO   
QTD2 = 100;
tresh(1:QTD2) = 22.02;

for i=1:QTD2
    filename = strcat(num2str(i),'.pgm');
    im{i} = imread(filename);
   % figure(i)  ,  imshow(im{i}) %Plot das figuras de entrada 
end

 
%MUDANDO O DOMÍNIO DAS IMAGENS - FFT 

for i=1:QTD 
    x{i} =  fftshift(fft(im2double(im{i})));    
end


%TRANFORMANDO AS MATRIZES EM VETORES 

for i=1:QTD
    X{i} = x{i}(:);
end 

%CONCATENANDO OS VETORES 
XX = [];
for i=1:QTD 
    XX = [XX X{i}];
end 


u = ones(1,QTD);
U = u';
[d N] = size(XX);

%ENERGIA 
D = [];
for i=1:QTD 
     D{i} = X{i}.*X{i};
end 

%CRIANDO UMA MATRIZ INVERSA 
S = 0;
for i = 1:QTD 
      
    S = S + D{i} ; 

end 

P = (1/N*d) * S ;

%IMPLEMENTAÇÃO DO FILTRO 


for i=1:d
    Dinv(i,1)=1/P(i,1);
end

for i=1:d
    for j=1:N
        temp(i,j) = Dinv(i,1) * XX(i,j);
    end
end

a =inv(ctranspose(XX) * temp);
h = temp * a * U; 

%TREINANDO O FILTRO PRA O CONJUNTO DE IMAGENS 

[d1 d2]=size(x{1});
Hmace=reshape(h,d1,d2);
save Hmace;

%FAZENDO A CORRELAÇÃO DAS IMAGENS COM O FILTRO 
load Hmace;
for i= 1:QTD2

    o=fftshift(fft(im2double(im{i})));
    c{i}=ifftshift(ifft2(o .* Hmace));
    g{i} = c{i}.*conj(c{i});
    %figure(i), mesh(g{i}) %plot das correlações das imagens
    
end 

 figure(2), mesh(g{1}) 
 
%COLETANDO AS MÁSCARAS PARA O CÁLCULO DO PSR E ENTÃO DEFINIÇÃO DO RESULTADO
j = 1;
k = 1;
soma = 0;
soma2 = 0;
soma5x5 = [];
soma20x20 = [];
for i = 1:QTD2
    for y=46:65
        for x=35:54
                   if((((y>53)&&(y<59))&&((x<49)&&(x>43))))
                       vetor{i}{j} =  g{i}(y,x);  %MATRIZ INTERNA 5x5
                       soma = soma + vetor{i}{j}; %GUARDANDO TODOS OS PONTOS DA MÁSCARA 5X5
                       soma5x5 = [soma5x5 soma];  %CONCATENANDO OS VALORES 
                       soma = 0;                  %ZERANDO PARA SALVAR O PRÓXIMO PONTO
                       j = j+1;
                   else 
                       vetor1{i}{k} = g{i}(y,x);  %MATRIZ EXTERNA 20x20 - 5x5
                       soma2 = soma2 + vetor1{i}{j};
                       soma20x20 = [soma20x20 soma2];
                       soma2 = 0;
                       k = k+1;
                   end
                        
        end
                 
    end
    j = 1;
    k = 1;
end

%DIVIDINDO OS VETORES DO PLANO 20x20
k = 1;
for i = 1:QTD2
    for j = 1:length(soma20x20)/QTD2
        INDI20(i,j) = soma20x20(k);
        k = k + 1;
    end
end

%DIVIDINDO OS VETORES DO PLANO 5x5
k = 1;
for i = 1:QTD2
    for j = 1:length(soma5x5)/QTD2
        INDI5(i,j) = soma5x5(k);
        k = k + 1;
    end
end

%CALCULANDO A MÉDIA DO PLANO 20X20
for i = 1:QTD2 
       
    media(i) = mean(INDI20(i,:)); 
        
end

%CALCULANDO O DESVIO PADRÃO DO PLANO 20X20
for i = 1:QTD2 
       
    desvp(i) = std(INDI20(i,:)); 
        
end

%CALCULANDO O PICO DO PLANO 5X5
for i = 1:QTD2 
       
   pico(i) = max(INDI5(i,:)); 
        
end

%CALCULANDO O PSR
for i = 1:QTD2 
       
   PSR(i) = (pico(i)-media(i))/desvp(i); 
        
end

%SOMANDO O NÚMERO DE IMAGENS QUE DERAM RESULTADO POSITIVO NAS IMAGENS
%TREINADAS 
val = 0;
for i = 1:QTD
    if PSR(i)>22
        val= val + 1;
    end
end

%SOMANDO O NÚMERO DE IMAGENS QUE DERAM RESULTADO POSITIVO NAS IMAGENS NO
%TOTAL
val1 = 0;
for i = QTD+1:QTD2
    if PSR(i)>22
        val1= val1 + 1;
    end
end

figure(1)
plot(1:QTD2,PSR);
xlabel('IMAGENS');
title('RESULTADOS','FontSize',14,'FontWeight','bold');
legend('PSR');
grid on 


