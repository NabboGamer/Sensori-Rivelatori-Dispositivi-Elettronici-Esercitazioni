function ordineDiGrandezza = calcolaOrdineDiGrandezza(numero)
    %CALCOLAORDINEDIGRANDEZZA calcola l'ordine di grandezza del numero in input
    
    if numero == 0
        % cprintf('SystemCommands', "L'ordine di grandezza non è definito per il numero zero \n");
        ordineDiGrandezza = NaN;
        return;
    end
    
    % Scrivo il numero in notazione scientifica
    % Notazione scientifica: numero = a * 10^b con 1 <= a < 10
    esponente = floor(log10(abs(numero)));  % Esponente iniziale b
    coefficiente = abs(numero) / 10^esponente;  % Coefficiente a
    
    % Determino l'ordine di grandezza
    if coefficiente < 5
        ordineDiGrandezza = esponente;
    else
        ordineDiGrandezza = esponente + 1;
    end
    
end

