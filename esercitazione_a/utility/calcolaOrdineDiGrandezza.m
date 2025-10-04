function ordineDiGrandezza = calcolaOrdineDiGrandezza(numero)
    %CALCULATEORDEROFMAGNITUDE calcola l'ordine di grandezza del numero in input
    
    if numero == 0
        cprintf('SystemCommands', "L'ordine di grandezza non è definito per il numero zero \n");
    end
    
    % Scriviamo il numero in notazione scientifica
    esponente = floor(log10(abs(numero)));  % Esponente iniziale b
    coefficiente = abs(numero) / 10^esponente;  % Coefficiente a
    
    % Determiniamo l'ordine di grandezza
    if coefficiente < 5
        ordineDiGrandezza = esponente;
    else
        ordineDiGrandezza = esponente + 1;
    end
    
end

