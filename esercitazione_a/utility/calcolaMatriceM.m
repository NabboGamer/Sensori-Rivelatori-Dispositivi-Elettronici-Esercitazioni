function M = calcolaMatriceM(ZoP, k_plate, l_plate)
    %CALCOLAMATRICEM permette di calcolare la matrice M per la piastra di adattamento
    
    % A (3×3): modello elettromeccanico del solo piezo
    % [F1, F2, V]^T = A[v1, v2, I]^T
    % 
    % B (2×2): piezo "ridotto" dopo aver fissato il lato sinistro, si ottiene 
    %          dalla relazione precedente ricavando v1 dalla prima riga e 
    %          sostituendolo nelle altre due 
    % [F2, V]^T = B[v2, I]^T
    % 
    % M (2×2): modello puramente meccanico di una piastra/layer interposto tra 
    %          piezo e carico ZL, si ottiene dalla prima relazione cancellando 
    %          tutti i termini con h33(fattore di accoppiamento elettro-meccanico)
    % [F3, F4]^T = M[v3, v4]^T
    M11 = ZoP ./ ( 1i .* tan(k_plate .* l_plate) );
    M12 = ZoP ./ ( 1i .* sin(k_plate .* l_plate) );
    M21 = M12;
    M22 = M11;
    
    M = {M11, M12; M21, M22};
end

