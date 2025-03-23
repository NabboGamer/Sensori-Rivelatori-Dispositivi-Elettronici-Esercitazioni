function stampaGrafici(f, modulo, fase, var, color, legendString, yAxisString)
    % STAMAPAGRAFICI permette di stampare i diagrammi di Bode dati il vettore delle frequenze (f), il modulo (modulo) e la fase (fase) del segnale
    
    if nargin < 7
        yAxisString = legendString;
    end

    if (color == "blue")
        color = '#0072BD';
    elseif (color == "orange")
        color = '#D95319';
    else
        color = 'none';
    end
    
    % Converto il vettore delle frequenze in megahertz(kHz) dividendo per 10^3
    f = f ./ 1e+03;
    % Converto il vettore dei moduli in kiloohm(kΩ) dividendo per 10^3
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || contains(var,'Comparing Zin without and with Backing'))
        modulo = modulo ./ 1e+03;
    end
   
    % Divido la figura corrente in una griglia 2x1 e creo una coppia di
    % assi nella posizione 1 che restituisco
    ax1 = subplot(2,1,1);
    modifiedLegendString = '|' + legendString + '|';
    modifiedyAxisString = '|' + yAxisString + '|';
    if (contains(var,'Zin: input impedance') || contains(var,'Impedance') || contains(var,'Comparing Zin without and with Backing'))
        loglog(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
        ylabel(ax1, modifiedyAxisString + ' [kΩ]');
    else
        semilogx(f, modulo, "Color", color, 'DisplayName', modifiedLegendString);
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
    elseif (contains(var,'Impedance'))
        % Viene disegnato un punto nero ('black.') alla frequenza e al 
        % modulo corrispondenti al massimo
        % Display Max
        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        % Viene aggiunta un'etichetta vicino al punto massimo, che include: 
        % il modulo massimo in dB e la frequenza corrispondente in MHz.
        text(f(1,index_max) + xOffset, modulo(index_max) + yOffset, ...
             strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), " [kΩ]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [kHz]") );

        % Disegno la linea verticale
        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';
   
        % Disegno il minimo 
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off');
        text(f(1,index_min) + xOffset, modulo(index_min) + yOffset, ...
             strcat("Min", [newline 'Module: '], " ", string(modulo(index_min)), " [kΩ]", [newline 'Frequency: '], " ", string(f(1,index_min)), " [kHz]") );

        % Disegno la linea verticale
        xmin = xline(f(1,index_min),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmin.LabelVerticalAlignment = 'bottom';
        xmin.LabelHorizontalAlignment = 'left';
    elseif (contains(var,'Comparing Zin without and with Backing'))
        % Disegno il massimo
        plot(f(1,index_max), modulo(index_max), 'black.', 'HandleVisibility','off');
        text(f(1,index_max) + xOffset, modulo(index_max) + yOffset, ...
            strcat("Max", [newline 'Module: '], " ", string(modulo(index_max)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]"));
        
        % Disegno la linea verticale
        xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmax.LabelVerticalAlignment = 'bottom';
        xmax.LabelHorizontalAlignment = 'left';

        % Disegno il minimo  
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off');
        text(f(1,index_min) + xOffset, modulo(index_min) + yOffset, ...
             strcat("Min", [newline 'Module: '], " ", string(modulo(index_min)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_min)), " [MHz]") );

        % Disegno la linea verticale
        xmin = xline(f(1,index_min),'-.', '','Color','black', 'HandleVisibility', 'off');
        xmin.LabelVerticalAlignment = 'bottom';
        xmin.LabelHorizontalAlignment = 'left';
    end

    % Aggiungo la legenda dinamicamente
    legend(ax1, 'Location', 'northeast');
    
    % Secondo subplot: fase
    ax2 = subplot(2,1,2);
    modifiedLegendString = 'Arg(' + legendString + ')';
    modifiedyAxisString = 'Arg(' + yAxisString + ')';
    semilogx(f, fase, "Color", color, 'DisplayName', modifiedLegendString);
    ylabel(ax2, modifiedyAxisString + ' [deg]');
    xlabel(ax2, 'Frequency [kHz]');
    grid on;
    hold on;
    
    % Aggiungo la legenda dinamicamente
    legend(ax2, 'Location', 'northeast');

    % Imposto titolo complessivo del grafico
    sgtitle(var)
end