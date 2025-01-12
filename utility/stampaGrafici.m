function stampaGrafici(f, modulo, fase, var, color)
    % STAMAPAGRAFICI permette di stampare i diagrammi di Bode dati il vettore delle frequenze (f), il modulo (modulo) e la fase (fase) del segnale
    
    if (color == "blue")
        color = '#0072BD';
    elseif (color == "orange")
        color = '#D95319';
    else
        color = none;
    end
    
    % Converto il vettore delle frequenze in megahertz(MHz) dividendo per 10^6
    f = f ./ 1e+06;
   
    if (~contains(var, 'Backing'))
        % Divido la figura corrente in una griglia 2x1 e creo una coppia di
        % assi nella posizione 1 che restituisco
        ax1 = subplot(2,1,1);
    else
        % Divido la figura corrente in una griglia 1x1 e creo una coppia di
        % assi nella posizione 1 che restituisco
        ax1 = subplot(1,1,1);
    end
   
    semilogx(f, modulo, "Color", color);
    xlabel(ax1,'Frequency [MHz]');
    ylabel(ax1,'Magnitude [dB]');
    grid on;
    hold on;
   
    index_min = (modulo == min(modulo));
    index_max = (modulo == max(modulo));
   
    if (contains(var,'Zi'))
        % Traccio una linea verticale tratteggiata ('-.) alla frequenza 
        % corrispondente al 50-esimo elemento di f, indicandola come flow.
        % flow sarebbe una frequenza bassa rispetto a fr dove la ceramica 
        % si comporta come un condensatore
        xlow = xline(f(1,50),'-.','flow = '+ string(f(1,50)) +' [MHZ]','Color','red');
        xlow.LabelVerticalAlignment = 'middle';
        xlow.LabelHorizontalAlignment = 'center';
        
        % Traccio una linea verticale al valore di frequenza corrispondente 
        % all'indice index_min, che rappresenta il valore minimo di modulo
        xa = xline(f(1,index_min),'-.','fa = '+ string(f(1,index_min)) +' [MHZ]','Color','red');
        xa.LabelVerticalAlignment = 'middle';
        xa.LabelHorizontalAlignment = 'center';
        
        % Stessa logica, ma applicata all'indice index_max, corrispondente 
        % al massimo valore del modulo.
        xr = xline(f(1,index_max),'-.','fr = '+ string(f(1,index_max)) +' [MHZ]','Color','red');
        xr.LabelVerticalAlignment = 'middle';
        xr.LabelHorizontalAlignment = 'center';
    elseif (contains(var,'Impedance Comparing'))
        % Viene disegnato un punto nero ('black.') alla frequenza e al 
        % modulo corrispondenti al massimo
        % Display Max
        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        % Viene aggiunta un'etichetta vicino al punto massimo, che include: 
        % il modulo massimo in dB e la frequenza corrispondente in MHz.
        text( f(1,index_max)+0.001, modulo(index_max)+0.01, ...
             strcat("Module: ", string(modulo(index_max)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]") );
   
        % Display Min 
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off');
        text(f(1,index_min)-0.03, modulo(index_min)+ 1, ...
             strcat("Module: ", string(modulo(index_min)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_min)), " [MHz]") );
    else
        if (~contains(var,'Backing'))
           plot(f(1,index_max), modulo(index_max), 'black.', 'HandleVisibility','off');
           text(f(1,index_max)+0.001, modulo(index_max)+ 0.01, ...
                strcat("Module: ", string(modulo(index_max)), " [dB]"));

           xmax = xline(f(1,index_max),'-.',string(f(1,index_max))+' [MHZ]','Color','black', 'HandleVisibility', 'off');
           xmax.LabelVerticalAlignment = 'bottom';
           xmax.LabelHorizontalAlignment = 'left';
        elseif(contains(var,'Comparing'))
            plot(f(1,index_max), modulo(index_max), 'black.', 'HandleVisibility','off');
            text( f(1,index_max)+0.001, modulo(index_max)+ 0.01, ...
                strcat("Module: ", string(modulo(index_max)), " [dB]", [newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]") );
        end
    end  
   
    if (~contains(var,'Backing'))
        % Se var non contiene "Backing", viene creato un secondo sotto-grafico per la fase
        ax2 = subplot(2,1,2);
        semilogx(f,fase);
        ylabel(ax2,'Phase [deg]');
        xlabel(ax2, 'Frequency [MHz]');
        grid on;
    end

    % Imposto titolo complessivo del grafico
    sgtitle(var)
end