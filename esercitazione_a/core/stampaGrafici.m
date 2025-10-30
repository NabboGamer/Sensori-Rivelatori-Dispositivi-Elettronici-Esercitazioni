function stampaGrafici(f, modulo, fase, var, color, legendString, yAxisString, additionalDescriptions, legendTitle)
    % STAMAPAGRAFICI permette di stampare i diagrammi di Bode dati il vettore delle frequenze (f), il modulo (modulo) e la fase (fase) del segnale
    
    if nargin < 7
        yAxisString = legendString;
        additionalDescriptions = "";
        legendTitle = "";
    end

    if nargin < 8
        additionalDescriptions = "";
        legendTitle = "";
    end

    if nargin < 9
        legendTitle = "";
    end

    if (color == "blue")
        color = '#0072BD';
    elseif (color == "orange")
        color = '#D95319';
    else
        color = 'none';
    end
    
    % Converto il vettore delle frequenze in kiloHertz(kHz) dividendo per 10^3
    f = f ./ 1e+03;
    % Converto il vettore dei moduli in kiloOhm(kΩ) dividendo per 10^3
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || ...
            contains(var,'Comparing Zin without and with Backing') || contains(var,'Impedence Comparing') || ...
            contains(var,'Comparing Zin without and with a correction') || ...
            contains(var,'Zin of the Langevin Ultrasonic Trasducer with the velocity Concentrator'))
        modulo = modulo ./ 1e+03;
    end
   
    % Divido la figura corrente in una griglia 2x1 e creo una coppia di
    % assi nella posizione 1 che restituisco
    ax1 = subplot(2,1,1);
    modifiedLegendString = '|' + legendString + '|' + additionalDescriptions;
    modifiedyAxisString = '|' + yAxisString + '|';
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || ...
            contains(var,'Comparing Zin without and with Backing') || contains(var,'Impedence Comparing') || ...
            contains(var,'Comparing Zin without and with a correction') || ...
            contains(var,'Zin of the Langevin Ultrasonic Trasducer with the velocity Concentrator'))
        % Quando il modulo è in kΩ (non in dB) il dato non è logaritmico ma può variare su più ordini di grandezza; 
        % per leggerlo meglio uso una scala logaritmica sull'asse Y
        loglog(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
        ylabel(ax1, modifiedyAxisString + ' [kΩ]');
    else
        semilogx(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
        ylabel(ax1, modifiedyAxisString + ' [dB]');
    end
    xlabel(ax1,'Frequency [kHz]');
    grid on;
    hold on;
    
    [~, index_min] = min(modulo);
    [~, index_max] = max(modulo);
   
    if (contains(var,'Zin: input impedance'))
        
        % Traccio una linea verticale tratteggiata (-.) alla frequenza 
        % corrispondente al 50-esimo elemento di f, indicandola come flow.
        % flow sarebbe una frequenza bassa rispetto a fr dove la ceramica 
        % si comporta come un condensatore
        xlow = xline(f(1,50),'-.','flow = '+ string(round(f(1,50))),'Color','red', 'DisplayName', 'Flow Line', 'HandleVisibility', 'off');
        xlow.LabelVerticalAlignment = 'middle';
        xlow.LabelHorizontalAlignment = 'center';
        
        % Traccio una linea verticale al valore di frequenza corrispondente 
        % all'indice index_min, che rappresenta il valore minimo di modulo
        xa = xline(f(1,index_min),'-.','fa = '+ string(round(f(1,index_min))),'Color','red', 'DisplayName', 'Fa Line', 'HandleVisibility', 'off');
        xa.LabelVerticalAlignment = 'middle';
        xa.LabelHorizontalAlignment = 'center';
        
        % Stessa logica, ma applicata all'indice index_max, corrispondente 
        % al massimo valore del modulo.
        xr = xline(f(1,index_max),'-.','fr = '+ string(round(f(1,index_max))),'Color','red', 'DisplayName', 'Fr Line', 'HandleVisibility', 'off');
        xr.LabelVerticalAlignment = 'middle';
        xr.LabelHorizontalAlignment = 'center';
    elseif (contains(var,'Impedance') || contains(var,'Impedence Comparing') || ...
            contains(var,'Impedence Comparing ARIA-ARIA') || contains(var,'Impedence Comparing ACQUA-ACQUA') ||...
            contains(var,'Comparing Zin without and with Backing') || contains(var,'Comparing Zin without and with a correction'))

        % Viene disegnato un punto nero ('black.') alla frequenza e al 
        % modulo corrispondenti al massimo
        % Display Max
        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        % Viene aggiunta un'etichetta vicino al punto massimo, che include: 
        % il modulo massimo in kΩ e la frequenza corrispondente in kHz.
        labelString = strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), [newline 'Frequency: '], " ", string(f(1,index_max)));
        safeText(ax1, f(1,index_max), modulo(index_max), labelString, 0.02, 0.02);

        % Disegno la linea verticale
        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';
   
        % Disegno il minimo 
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off');
        labelString = strcat("Min", [newline 'Module: '], " ", string(modulo(index_min)), [newline 'Frequency: '], " ", string(f(1,index_min)));
        safeText(ax1, f(1,index_min), modulo(index_min), labelString, 0.02, -0.02);

        % Disegno la linea verticale
        xmin = xline(f(1,index_min),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmin.LabelVerticalAlignment = 'bottom';
        xmin.LabelHorizontalAlignment = 'left';
    elseif (contains(var,'Zin of the Langevin Ultrasonic Trasducer with the velocity Concentrator') || ...
            contains(var,'TTF of the Langevin Ultrasonic Trasducer with the velocity Concentrator'))

        % N.B.: Qui sto lavorando in kHz quindi il e+03 scompare
        target = 40;

        [~, idx] = min(abs(f - target));
        x0 = f(idx);
        y0 = modulo(idx);
        
        xline(ax1, x0, '-.','Color','k', 'HandleVisibility','off');
        
        hold(ax1,'on');
        m = plot(ax1, x0, y0, 'o', 'MarkerFaceColor','w', 'MarkerEdgeColor','k', 'HandleVisibility','off');
        uistack(m,'top');  % porta il marker in primo piano
        
        labelString = sprintf('Module: %.3f\nFrequency: %.3f kHz', y0, x0);
        safeText(ax1, x0, y0, labelString, 0.02, 0.02);

    elseif (contains(var,'TTF') || contains(var,'TTF Comparing') || contains(var,'RTF Comparing') || ...
            contains(var,'TTF Comparing ARIA-ARIA') || contains(var,'RTF Comparing ARIA-ARIA') || ...
            contains(var,'TTF Comparing ACQUA-ACQUA') || contains(var,'RTF Comparing ACQUA-ACQUA') || ...
            contains(var,'TTF side 1 Comparing') || contains(var,'TTF side 2 Comparing') || ...
            contains(var,'RTF side 1 Comparing') || contains(var,'RTF side 2 Comparing') || ...
            contains(var,'Comparing TTF without and with Backing') || contains(var,'Comparing RTF without and with Backing') || ...
            contains(var,'Comparing TTF without and with a correction'))

        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        labelString = strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), [newline 'Frequency: '], " ", string(f(1,index_max)));
        safeText(ax1, f(1,index_max), modulo(index_max), labelString, 0.02, 0.02);

        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';
    end

    % Aggiungo la legenda dinamicamente
    lgd1 = legend(ax1, 'Location', 'northeast');
    title(lgd1, legendTitle);
    set(ax1,'XMinorTick','on','YMinorTick','on');
    
    % Secondo subplot: fase
    ax2 = subplot(2,1,2);
    modifiedLegendString = 'Arg(' + legendString + ')' + additionalDescriptions;
    modifiedyAxisString = 'Arg(' + yAxisString + ')';
    semilogx(f, fase, "Color", color, 'DisplayName', modifiedLegendString);
    ylabel(ax2, modifiedyAxisString + ' [deg]');
    xlabel(ax2, 'Frequency [kHz]');
    grid on;
    hold on;
    
    % Aggiungo la legenda dinamicamente
    lgd2 = legend(ax2, 'Location', 'northeast');
    title(lgd2, legendTitle);
    set(ax2,'XMinorTick','on','YMinorTick','on');

    % Imposto titolo complessivo del grafico
    sgtitle(var)
end