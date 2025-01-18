function G = calcolaMatriceG(A, B)
    %CALCOLAMATRICEG permette di calcolare la matrice G per la coppia di ceramiche date le matrici A e B. 
    
    % È importante notare il fatto che B qui rappresenta sempre la matrice 
    % A ma per il secondo 3-bipolo, non ha nulla a che fare con la matrice 
    % B vera e propria. Quindi è normale che vi siano accessi a elementi
    % come il 4 del Cell Array poichè essa è sempre una matrice 3x3.
    G11 = A{1} - ( (A{2}.^2) ./ (A{1} + B{1}) );

    G12 = (A{2} .* B{2}) ./ (A{1} + B{1});

    G13 = ( A{3} - ((A{2}.*A{3})./(A{1}+B{1})) + ((A{2}.*B{3})./(A{1}+B{1})) ) ./ 2;

    % In teoria G22 e G23 hanno valori differenti da G11 e G13, questo
    % però accade soltanto se A e B(quindi la A del secondo 3-bipolo) sono
    % differenti nei valori ovvero accade soltanto se i due 3-bipoli hanno
    % valori differenti per i parametri caratteristici e questo nella
    % nostra modellazione non è contemplato. Ciò spiega il perchè non li
    % aggiungo al Cell Array che di conseguenza può essere utilizzato senza
    % distinzione per il calcolo della vera matrice B della coppia di ceramiche.
    %--------------------------------------------------------------------------------%
    G22 = B{1} - ( (B{2}.^2) ./ (A{1} + B{1}) );
    G23 = ( B{3} - ((B{2}.*B{3})./(A{1}+B{1})) + ((A{3}.*B{2})./(A{1}+B{1})) ) ./ 2;
    %--------------------------------------------------------------------------------%

    G33 = ( ...
          (A{4}./2) + ...
          (B{4}./2) - ...
          ( (B{3}.^2) ./ (2.*(A{1}+B{1})) ) - ...
          ( (A{3}.^2) ./ (2.*(A{1}+B{1})) ) + ...
          ( (A{3}.*B{3}) ./ (A{1}+B{1}) ) ...
          ) ./ 2;
    
    G = {G11, G12, G13, G33};
end

