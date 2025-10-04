function stampaGrafici(f, modulo, fase, var, color, legendString, yAxisString, additionalDescriptions)
    % STAMAPAGRAFICI permette di stampare i diagrammi di Bode dati il vettore delle frequenze (f), il modulo (modulo) e la fase (fase) del segnale
    
    if nargin < 7
        yAxisString = legendString;
        additionalDescriptions = "";
    end

    if nargin < 8
        additionalDescriptions = "";
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
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || contains(var,'Comparing Zin without and with Backing') || contains(var,'Impedence Comparing'))
        modulo = modulo ./ 1e+03;
    end
   
    % Divido la figura corrente in una griglia 2x1 e creo una coppia di
    % assi nella posizione 1 che restituisco
    ax1 = subplot(2,1,1);
    modifiedLegendString = '|' + legendString + '|' + additionalDescriptions;
    modifiedyAxisString = '|' + yAxisString + '|';
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || contains(var,'Comparing Zin without and with Backing') || contains(var,'Impedence Comparing'))
        semilogy(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
        ylabel(ax1, modifiedyAxisString + ' [kΩ]');
    else
        plot(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
        ylabel(ax1, modifiedyAxisString + ' [dB]');
    end
    xlabel(ax1,'Frequency [kHz]');
    grid on;
    hold on;
   
    index_min = (modulo == min(modulo));
    index_max = (modulo == max(modulo));

    % Ottengo i limiti degli assi
    xLimits = xlim;
    yLimits = ylim;
    
    % Calcolo uno spostamento proporzionale
    xOffset = (xLimits(2) - xLimits(1)) * 0.01; % Spostamento del 1% rispetto alla larghezza dell'asse X
    yOffset = (yLimits(2) - yLimits(1)) * 0.01; % Spostamento del 1% rispetto all'altezza dell'asse Y
   
    if (contains(var,'Zin: input impedance'))
        
        % Traccio una linea verticale tratteggiata ('-.) alla frequenza 
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
            contains(var,'Comparing Zin without and with Backing'))

        % Viene disegnato un punto nero ('black.') alla frequenza e al 
        % modulo corrispondenti al massimo
        % Display Max
        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        % Viene aggiunta un'etichetta vicino al punto massimo, che include: 
        % il modulo massimo in kΩ e la frequenza corrispondente in kHz.
        safeText(ax1, f(1,index_max), modulo(index_max), ...
                 strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), " [kΩ]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [kHz]"), ...
                 0.5, 0.0);

        % Disegno la linea verticale
        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';
   
        % Disegno il minimo 
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off'); 
        safeText(ax1, f(1,index_min), modulo(index_min), ...
                 strcat("Min", [newline 'Module: '], " ", string(modulo(index_min)), " [kΩ]", [newline 'Frequency: '], " ", string(f(1,index_min)), " [kHz]"), ...
                 0.5, 0.0);

        % Disegno la linea verticale
        xmin = xline(f(1,index_min),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmin.LabelVerticalAlignment = 'bottom';
        xmin.LabelHorizontalAlignment = 'left';
    elseif (contains(var,'TTF Comparing') || contains(var,'RTF Comparing') || ...
            contains(var,'TTF Comparing ARIA-ARIA') || contains(var,'RTF Comparing ARIA-ARIA') || ...
            contains(var,'TTF Comparing ACQUA-ACQUA') || contains(var,'RTF Comparing ACQUA-ACQUA') || ...
            contains(var,'TTF side 1 Comparing') || contains(var,'TTF side 2 Comparing') || ...
            contains(var,'RTF side 1 Comparing') || contains(var,'RTF side 2 Comparing') || ...
            contains(var,'Comparing TTF without and with Backing') || contains(var,'Comparing RTF without and with Backing'))

        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        safeText(ax1, f(1,index_max), modulo(index_max), ...
                 strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [kHz]"), ...
                 0.5, 0.0);

        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';
    end

    % Aggiungo la legenda dinamicamente
    legend(ax1, 'Location', 'northeast');
    
    % Secondo subplot: fase
    ax2 = subplot(2,1,2);
    modifiedLegendString = 'Arg(' + legendString + ')' + additionalDescriptions;
    modifiedyAxisString = 'Arg(' + yAxisString + ')';
    plot(f, fase, "Color", color, 'DisplayName', modifiedLegendString);
    ylabel(ax2, modifiedyAxisString + ' [deg]');
    xlabel(ax2, 'Frequency [kHz]');
    grid on;
    hold on;
    
    % Aggiungo la legenda dinamicamente
    legend(ax2, 'Location', 'northeast');

    % Imposto titolo complessivo del grafico
    sgtitle(var)
end