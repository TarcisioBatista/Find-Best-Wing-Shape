%Entrada
%Cmax = corda maxima
%b = envergadura
%n = numero de afilamentos
%Saída
%best = melhor configuração de asa
%S = area da best
%Foma do Individuo matriz 2 x n
%n=3
%Cmax=0.3;

function[best,L] = findAsa(Cmax,n)
    popSize = 100; %numero de individuos
    pop = zeros(popSize,n+1);
    filhos = zeros(popSize,n+1);
    cordas = zeros(n,1);
    cordas(1) = Cmax;
    save cordas;
    muteRate = 0.7;
    gen = 100 ; 
    bests = zeros(1,gen);
    for i=2:n
        cordas(i) = cordas(i-1)*0.618;
    end
    %gerando população inicial, respeitando restrições
    for i=1:(popSize*10)
        pop(i,1:n-1) = rand(1,n-1)*.25; %limitar a envergadura maxima
        pop(i,n) = .5 - sum(pop(i,1:n-1));
        [pop(i,n+1),~] = fitAsa(pop(i,1:n),cordas);
    end
    
    pop = sortrows(pop,-(n+1));
    best = pop(1,:);
    [~,L]= fitAsa(best(1:n),cordas);
    bests(1) = best(n+1);
    aux = find(pop(:,n+1)==-Inf);
    aux = aux(1);
    if(mod(aux,2))
        pop = pop(1:(aux-1),:);
        popSize = aux-1;
    else
        pop = pop(1:(aux-2),:);
        popSize = aux-2;
    end
    
    count = 0;
    t = 2;
    for k=1:gen
        %cruzamento
        %{
        i = 1;
        while(i<popSize)
            while(1)
                a = randi(popSize/2);
                b = randi(popSize/2);
                if((a ~= b) && pop(a,n+1)>0 && pop(b,n+1)>0);
                    break;
                end
            end
            aux = randperm(n);
            sumf1 = 0;
            sumf2 = 0;
            j = 1;
            while(j <= (n-1)/2)
                filhos(i,aux(j)) = pop(a,aux(j));
                filhos(i,aux(j+1)) = pop(b,aux(j+1));
                sumf1 = sumf1 + filhos(i,aux(j)) + filhos(i,aux(j+1));
                filhos(i+1,aux(j)) = pop(b,aux(j));
                filhos(i+1,aux(j+1)) = pop(a,aux(j+1));
                sumf2 = sumf2 + filhos(i+1,aux(j)) + filhos(i+1,aux(j+1));
                if(sumf1 < 0.5 && sumf2 < 0.5)
                    j = j + 2;
                else
                    aux = randperm(n);
                    sumf1 = 0;
                    sumf2 = 0;
                    j = 1;
                end
            end
            filhos(i,aux(n)) = 0.5 - sumf1;
            filhos(i+1,aux(n)) = 0.5 - sumf2;
            i = i+2;
        end
        %}
        
        %cruzamento dois (m�dia polarizada)
        i = 1;
        while(i<=popSize)
            while(1)
                a = randi(popSize/2);
                b = randi(popSize/2);
                if(a ~= b);
                    break;
                end
            end            
            if(pop(a,n+1)>pop(b,n+1))
                filhos(i,1:n) = (pop(a,1:n)*3+pop(b,1:n))./4;
            else
                filhos(i,1:n) = (pop(b,1:n)*3+pop(a,1:n))./4;
            end
            
        [filhos(i,n+1),~] = fitAsa(filhos(i,1:n),cordas); 
        i = i+1;
        end
        filhos = sortrows(filhos,-(n+1));
        if(best(n+1) < pop(1,n+1))
            best = pop(1,1:n+1);
            [~,L]= fitAsa(best(1:n),cordas);
        end
        
        
        %muta��o sugest�o de J�ao somar um rand de uma se��o e subtrair de
        %outra, nada pronto ainda.
        
        %muta��o, mutando os individuos em rala��o a taxa de muta��o
        %{
        j = 1;
        while(j<popSize)
            if(muteRate > rand())
                while(1)
                    a = randi(n-1);
                    b = randi(n-1);
                    if(a ~= b )
                        break;
                    end
                end
                
                aux = filhos(j,a);
                filhos(j,a) = filhos(j,b);
                filhos(j,b) = aux;
                [filhos(j,n+1),~] = fitAsa(filhos(j,1:n),cordas);
                %{
                aux = pop(j,a);
                pop(j,a) = pop(j,b);
                pop(j,b) = aux;
                [pop(j,n+1),~] = fitAsa(pop(j,1:n),cordas);
                %}
                j = j+1; 
            end
        end
        %}
        %muta��o 2 (soma um poquinho e subtrai um pouquinho)
        j = 1;
        while(j<=popSize)
            if(muteRate > rand())
                while(1)
                    a = randi(n-1);
                    b = randi(n-1);
                    aux = rand()*0.125;
                    if(a ~= b && filhos(j,b)>aux)%garantindo muta��es validas
                        filhos(j,a) = filhos(j,a) + aux;
                        filhos(j,b) = filhos(j,b) - aux;
                        [filhos(j,n+1),~] = fitAsa(filhos(j,1:n),cordas);
                        j = j+1;
                        break;
                    end
                end                
            end
        end
        
        
        
        %sele��o, unindo a popula��o geral, salvando os 50 melhores
        %individuos e gerando uma nova população, sempre o melhor individuo
        %ser� salvo
        pop = [pop;filhos];
        pop = sortrows(pop,-(n+1));
        pop = pop(1:popSize,:);
        if(best(n+1) < pop(1,n+1))
            best = pop(1,1:n+1);
            [~,L]= fitAsa(best(1:n),cordas);
        end
        if(k<gen)
            bests(t) = best(n+1);
            if(bests(t) == bests(t-1))
                count = count +1;
                if(count > 50)
                    break;
                end
            else
                count = 0;
            end
            t = t+1;
        end
        
    end
    plot(1:gen,bests(1,:));
end