function [modulo, fase] = calcolaModuloEFase(numeroComplesso, useDBForModule, useDegForPhase)
    % CALCOLAMODULOEFASE calcola modulo(dB/Ω) e fase(deg/rad) di un numero complesso
    
    if useDBForModule
        modulo = mag2db(abs(numeroComplesso)); % dB
    else
        modulo = abs(numeroComplesso);
    end
    
    if useDegForPhase
        fase = rad2deg(angle(numeroComplesso)); % deg
    else
        fase = angle(numeroComplesso); % rad
    end

end