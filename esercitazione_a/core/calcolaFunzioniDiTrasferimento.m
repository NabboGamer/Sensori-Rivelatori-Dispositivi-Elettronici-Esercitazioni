function [Zin, FTT, FTR] = calcolaFunzioniDiTrasferimento(B, Z, Zel)
    %CALCOLAFUNZIONIDITRASFERIMENTO permette di calcolare Zin, FTT e FTR per della ceramica piezoelettrica schematizzata come un 3-bipolo
    
    Zin = B{2,2} - ( (B{1,2} .^ 2) ./ (Z + B{1,1}) );
    [moduloZin, faseZin] = calcolaModuloEFase(Zin, false, true);
    Zin = {moduloZin, faseZin};
    
    FTT = ( Z .* B{1,2} ) ./ ( (B{2,2} .* (B{1,1} + Z)) - B{1,2} .^ 2);
    [moduloFTT, faseFTT] = calcolaModuloEFase(FTT, true, true);
    FTT = {moduloFTT, faseFTT};
    
    FTR = (Zel .* B{1,2}) ./ ( (B{1,1} .* (B{2,2} + Zel)) - (B{1,2} .^ 2) );
    [moduloFTR, faseFTR] = calcolaModuloEFase(FTR, true, true);
    FTR = {moduloFTR, faseFTR};
    
end