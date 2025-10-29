function M = calcolaMatriceMFormulazioneAlternativa(k, S, Y, omega, L)
    %CALCOLAMATRICEMFORMULAZIONEALTERNATIVA permette di calcolare la matrice M per uno strato puramente meccanico
    
    M11 = (k .* S .* Y) ./ (1i .* omega .* tan(k .* L));
    M12 = (k .* S .* Y) ./ (1i .* omega .* sin(k .* L));
    M21 = M12;
    M22 = M11;

    M = {M11, M12; M21, M22};

end