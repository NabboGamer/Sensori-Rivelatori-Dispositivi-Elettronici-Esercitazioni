function calcolaStatistiche(tabellaScore)

    %% Etichetto i confronti come genuini o impostori
    for i = 1 : height(tabellaScore)
        template1 = char(tabellaScore.Template1(i));
        idx1 = find(template1 == '_', 1, 'first');
        nomeUtente1 = template1(1:idx1-1);
    
        template2 = char(tabellaScore.Template2(i));
        idx2 = find(template2 == '_', 1, 'first');
        nomeUtente2 = template2(1:idx2-1);
            
        if(strcmp(nomeUtente1,nomeUtente2)) 
            tabellaScore.Risultato(i) = {'Genuino'}; 
        else
            tabellaScore.Risultato(i) = {'Impostore'};
        end
    end
    
    %% Ricavo la tabella genuini e impostori
    tabellaGenuinoML = cell(1,3);
    tabellaImpostoreML = cell(1,3);
    genuino = 0;
    impostore = 0;
    
    for i=1:height(tabellaScore)
    
        risultato = tabellaScore{i,4};
    
        if (strcmp(risultato,'Genuino'))
            genuino = genuino + 1;
            tabellaGenuinoML(genuino,1) = {tabellaScore.Template1(i)};
            tabellaGenuinoML(genuino,2) = {tabellaScore.Template2(i)};
            tabellaGenuinoML(genuino,3) = {round(tabellaScore{i,3}*100)};
        else
            impostore = impostore + 1;
            tabellaImpostoreML(impostore,1) = {tabellaScore.Template1(i)};
            tabellaImpostoreML(impostore,2) = {tabellaScore.Template2(i)};
            tabellaImpostoreML(impostore,3) = {round(tabellaScore{i,3}*100)};
    
        end
        
    end
    
    tabellaGenuini   = cell2table(tabellaGenuinoML,   'VariableNames',{'Utente1' 'Utente2' 'Score'});
    tabellaImpostori = cell2table(tabellaImpostoreML, 'VariableNames',{'Utente1' 'Utente2' 'Score'});
    
    %% Plot grafico distribuzione Genuini-Impostori
    occorenzeGenuini=zeros(1,100);
    occorenzeImpostori=zeros(1,100);
    
    for i=1:height(tabellaGenuini)
       valore = tabellaGenuini.Score(i);
       occorenzeGenuini(1,valore) = occorenzeGenuini(1 , valore) + 1;
    end
    
    for i=1:height(tabellaImpostori)
       valore = tabellaImpostori.Score(i);
       occorenzeImpostori(1,valore) = occorenzeImpostori(1 , valore) + 1;
    end
    
    % Normalizzazione indici
    max_genuino = max(occorenzeGenuini);
    occorenzeGenuini_norm = occorenzeGenuini/max_genuino;
    max_impostore = max(occorenzeImpostori);
    occorenzeImpostori_norm =occorenzeImpostori/max_impostore;
    
    approssimazione = 0.01;
    intervalli = 1/approssimazione;
    
    % Grafico occorrenze degli score degli impostori e dei genuini NORMALIZZATI
    figure(1);
    axes('FontSize',10,'FontName','Times New Roman');
    ylim([0 1.05]);
    box on;
    hold on;
    plot(approssimazione:approssimazione:1,occorenzeImpostori_norm,'LineWidth', 1.5);
    xlabel('Score','FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('Normalized Frequency','FontSize', 12, 'FontName', 'Times New Roman');
    plot(approssimazione:approssimazione:1,occorenzeGenuini_norm,'Color','red','LineWidth', 1.5);
    legend('Impostori', 'Genuini');
    pbaspect([1 1 1]);
    hold off;
    
    %% Plot curve FAR ed FRR

    % Calcolo il FAR
    indice = 0;
    for soglia = 0:approssimazione:1
        indice = indice+1;
        if(soglia > 0)
            somma = 0;
            for i = 1:(soglia/approssimazione)
                if(occorenzeImpostori(1,i) > 0)
                    somma = somma+occorenzeImpostori(1,i);
                end
            end
            vettoreFAR(1,indice) = (sum(occorenzeImpostori)-somma)/sum(occorenzeImpostori);
        else
            vettoreFAR(1,indice) = 1;
        end
    end

    % Calcolo il FRR
    indice = 0;
    for soglia = 0:approssimazione:1
        indice = indice+1;
        if(soglia > 0) 
            somma = 0;
            for i = 1:(soglia/approssimazione)
                if(occorenzeGenuini(1,i) > 0)
                    somma = somma+occorenzeGenuini(1,i);
                end
            end
            vettoreFRR(1,indice) = somma/sum(occorenzeGenuini);
        else
            vettoreFRR(1,indice) = 0;
        end
    end

    %Plot curve FAR-FRR interpolati
    far_interp = interp1(1:intervalli+1, vettoreFAR, 1:0.1:intervalli+1, 'pchip'); %0.1 sarebbe dividere per 10 un tratto = 9 punti in più per ogni 2 punti del vettore... (12-1)*9 + 12
    frr_interp = interp1(1:intervalli+1, vettoreFRR, 1:0.1:intervalli+1, 'pchip'); %0.1 sarebbe dividere per 10 un tratto = 9 punti in più per ogni 2 punti del vettore... (12-1)*9 + 12
    figure(2);
    axes('FontSize',10,'FontName','Times New Roman');
    ylim([0 1.05]);
    box on;
    hold on;
    plot(0:0.001:1,far_interp,'LineWidth', 1.5);
    xlabel('threshold t','FontSize',12, 'FontName', 'Times New Roman');
    ylabel('error probability','FontSize',12, 'FontName', 'Times New Roman');
    plot(0:0.001:1, frr_interp, 'Color', 'red', 'LineWidth', 1.5);
    legend('FAR', 'FRR');
    pbaspect([1 1 1]);

    %% Calcolo dell'EER: punto in cui FAR e FRR sono più vicine
    
    numPuntiSoglia = length(far_interp);   % numero di campioni di soglia considerati
    passoSogliaPlot = 0.001;               % lo stesso passo usato nel plot (0:0.001:1)
    
    distanzaMetaFAR_FRR = zeros(1, numPuntiSoglia);
    valoriSogliaPlot   = zeros(1, numPuntiSoglia);
    
    for idx = 1:numPuntiSoglia
        % metà della differenza assoluta tra FAR e FRR in quel punto
        % (serve solo per trovare dove le curve sono più vicine)
        distanzaMetaFAR_FRR(1, idx) = abs(far_interp(1, idx) - frr_interp(1, idx)) / 2;
        
        % soglia corrispondente a questo indice (per coerenza con il plot 0:0.001:1)
        valoriSogliaPlot(1, idx) = idx * passoSogliaPlot;
    end
    
    % Trovo il punto in cui FAR e FRR sono più vicine (distanza minima)
    [~, indiceMinDistanza] = min(distanzaMetaFAR_FRR);
    
    % Soglia corrispondente all'EER (ascissa)
    sogliaEER = (indiceMinDistanza - 1) * passoSogliaPlot;
    
    % Valore di EER (ordinata), preso dalla FAR (che ≃ FRR in quel punto)
    valoreEER = far_interp(indiceMinDistanza);
    
    plot(sogliaEER, valoreEER, 'x', 'MarkerSize', 10, 'LineWidth', 2, 'Color', 'k', 'HandleVisibility', 'off');
    text(sogliaEER, valoreEER, 'EER', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontName', 'Times New Roman');
    hold off;
    
    cprintf('Comments', "Il valore di EER è: %s\n", string(valoreEER));

    %% Plot curva DET
    vettore_far_ml = vettoreFAR.*100;
    vettore_frr_ml = vettoreFRR.*100;

    figure(3);
    axes('FontSize',10,'FontName','Times New Roman');
    box on;
    hold on;
    plot(vettore_far_ml, vettore_frr_ml, 'LineWidth', 1.5);
    xlabel('False Acceptance Rate (%)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('False Rejection Rate (%)', 'FontSize', 12, 'FontName', 'Times New Roman');
    plot([0 100],[0 100],'k','LineWidth',0.1);
    pbaspect([1 1 1]);

end
