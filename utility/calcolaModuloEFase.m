function [modulo, fase] = calcolaModuloEFase(numeroComplesso)
    % CALCOLAMODULOEFASE calcola modulo(dB) e fase(deg) di un numero complesso
    
    modulo = mag2db(abs(numeroComplesso)); % dB

    fase = rad2deg (angle(numeroComplesso)); % deg

end