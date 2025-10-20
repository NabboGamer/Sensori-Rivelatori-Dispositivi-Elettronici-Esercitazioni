function [modulo, fase] = calcolaModuloEFase(numeroComplesso, usaDBPerModulo, usaDegPerFase)
    % CALCOLAMODULOEFASE calcola modulo(dB/Ω) e fase(deg/rad) di un numero complesso
    
    if usaDBPerModulo
        modulo = mag2db(abs(numeroComplesso)); % dB
    else
        modulo = abs(numeroComplesso);
    end
    
    if usaDegPerFase
        fase = rad2deg(angle(numeroComplesso)); % deg
    else
        fase = angle(numeroComplesso); % rad
    end

end