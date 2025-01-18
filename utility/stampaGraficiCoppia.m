function stampaGraficiCoppia(f, Z1, Z2, valoreCoppia, valore, var, posizione)
    %STAMPAGRAFICICOPPIA permette di stampare

    if(Z1 ~= Z2)
        subplot(2,1,posizione)
    end

    f = f./1e+06;
    
    semilogx(f, valoreCoppia{1});
    title(var);
    ylabel('Magnitude [dB]');
    xlabel("Frequency [MHz]");
    grid on;
    hold on;
    semilogx(f, valore{1});
    legend('Two Ceramics','One ceramic');
    grid on;
    hold on;

    plot(f(1,1), valore{1}(1), 'black.', 'HandleVisibility', 'off');
    text(f(1,1)-0.005, valore{1}(1), strcat("Module: ", string(valore{1}(1)), " [dB]"));%, [newline 'Frequency: '], " ", string(f(1,1)), " [MHz]"));
     
    plot(f(1,1), valoreCoppia{1}(1), 'black.', 'HandleVisibility','off');
    text(f(1,1)-0.005, valoreCoppia{1}(1), strcat("Module: ", string(valoreCoppia{1}(1)), " [dB]"));%, [newline 'Frequency: '], " ", string(f(1,1)), " [MHz]"));

end