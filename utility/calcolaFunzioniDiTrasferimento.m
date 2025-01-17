function [Zin, FTT, FTR] = calcolaFunzioniDiTrasferimento(B, Z, Zel)
    %CALCOLAFUNZIONIDITRASFERIMENTO permette di calcolare Zin, FTT e FTR per della ceramica piezoelettrica schematizzata come un 3-bipolo
    
    Zin = B{3} - ( (B{2} .^ 2) ./ (Z + B{1}) );
    [moduloZin, faseZin] = calcolaModuloEFase(Zin);
    Zin = {moduloZin, faseZin};
    
    FTT = ( Z .* B{2} ) ./ ( (B{3} .* (B{1} + Z)) - B{2} .^ 2);
    [moduloFTT, faseFTT] = calcolaModuloEFase(FTT);
    FTT = {moduloFTT, faseFTT};
    
    % FTT_i = ( (Z .* B{2}) ./ ( (B{3} .* (B{1} + Z)) - B{2} .^ 2)) .* Zin;
    % [moduloFTT_i, faseFTT_i] = calcolaModuloEFase(FTT_i);
    % FTT_i = {moduloFTT_i, faseFTT_i};
    
    FTR = (Zel .* B{2}) ./ ( (B{1} .* (B{3} + Zel)) - (B{2} .^ 2) );
    [moduloFTR, faseFTR] = calcolaModuloEFase(FTR);
    FTR = {moduloFTR, faseFTR};
    
end

