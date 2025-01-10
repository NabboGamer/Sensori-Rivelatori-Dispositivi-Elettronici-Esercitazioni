function stampaGrafici(f, modulo, fase, var, color)
    % STAMAPAGRAFICI permette di stampare i diagrammi di Bode dati il vettore delle frequenze (f), il modulo (modulo) e la fase (fase) del segnale
    
    if(color == "blue")
        color = '#0072BD';
    elseif(color == "orange")
        color = '#D95319';
    else
        color = none;
    end
    
    % Converto il vettore delle frequenze in megahertz(MHz) dividendo per 10^6
    f = f ./ 1e+06;
   
    if(~contains(var, 'Backing'))
        % Divido la figura corrente in una griglia 2x1 e creo una coppia di
        % assi nella posizione 1 che restituisco
       ax1 = subplot(2,1,1);
    else
        % Divido la figura corrente in una griglia 1x1 e creo una coppia di
        % assi nella posizione 1 che restituisco
       ax1 = subplot(1,1,1);
    end
   
    semilogx(f, modulo, "Color", color);
    xlabel(ax1,'Frequencies [MHz]');
    ylabel(ax1,'Magnitude [dB]');
    
    grid on;
    hold on;
   
    index_min = modulo == min(modulo);
    index_max = modulo == max(modulo);
   
    if(contains(var,'Zi'))
        xlow = xline(f(1,100),'-.','flow = '+ string(f(1,100)) +' [MHZ]','Color','red');
        xlow.LabelVerticalAlignment = 'middle';
        xlow.LabelHorizontalAlignment = 'center';
   
        xa = xline(f(1,index_min),'-.','fa = '+ string(f(1,index_min)) +' [MHZ]','Color','red');
        xa.LabelVerticalAlignment = 'middle';
        xa.LabelHorizontalAlignment = 'center';
   
        xr = xline(f(1,index_max),'-.','fr = '+ string(f(1,index_max)) +' [MHZ]','Color','red');
        xr.LabelVerticalAlignment = 'middle';
        xr.LabelHorizontalAlignment = 'center';
    elseif(contains(var,'Impedance Comparing'))
        % Display Max
        plot(f(1,index_max), modulo(index_max), 'black.','HandleVisibility','off');
        text(f(1,index_max)+0.001, modulo(index_max)+0.01, ...
             strcat("Module: ", string(modulo(index_max)), " [dB]", ...
             [newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]"));
   
        % Display Min 
        plot(f(1,index_min), modulo(index_min), 'black.', 'HandleVisibility','off');
        text(f(1,index_min)-0.03, modulo(index_min)+ 1, ...
             strcat("Module: ", string(modulo(index_min)), " [dB]", ...
             [newline 'Frequency: '], " ", string(f(1,index_min)), " [MHz]"));    
   
    else
        if(~contains(var,'Backing'))
           plot(f(1,index_max), modulo(index_max), 'black.', 'HandleVisibility','off');
           text(f(1,index_max)+0.001, modulo(index_max)+ 0.01, ...
                strcat("Module: ", string(modulo(index_max)), " [dB]"))%,...
                %[newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]"));
           xmax = xline(f(1,index_max),'-.',string(f(1,index_max))+' [MHZ]','Color','black', 'HandleVisibility', 'off');
           xmax.LabelVerticalAlignment = 'bottom';
           xmax.LabelHorizontalAlignment = 'left';
        elseif(contains(var,'Comparing'))
            plot(f(1,index_max), modulo(index_max), 'black.', 'HandleVisibility','off');
            text(f(1,index_max)+0.001, modulo(index_max)+ 0.01, ...
                strcat("Module: ", string(modulo(index_max)), " [dB]",...
                [newline 'Frequency: '], " ", string(f(1,index_max)), " [MHz]"));
        end
    %  else
    %      plot(f(1,index_max), db2mag(modulo(index_max)), 'black.', 'HandleVisibility','off');
    %      text(f(1,index_max)+0.001, db2mag(modulo(index_max)+ 0.01), ...
    %           strcat("Module: ", string(db2mag(modulo(index_max))), " [\Omega]"))%, ...
    %           %[newline 'Frequency: '], " ", string(f(1,index_min)), " [MHz]"));
    %      xmax = xline(f(1,index_max),'-.',string(f(1,index_max))+' [MHZ]','Color','black', 'HandleVisibility', 'off');
    %      xmax.LabelVerticalAlignment = 'bottom';
    %      xmax.LabelHorizontalAlignment = 'right';
    end  
   
    if(~contains(var,'Backing'))
        ax2 = subplot(2,1,2);
        semilogx(f,fase);
        ylabel(ax2,'Phase [degree]');
        xlabel('Frequency [MHz]');
        grid on;
    end
    sgtitle(var)
end